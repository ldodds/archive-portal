require 'rubygems'
require 'bundler'
require 'csv'
require 'zip'

Bundler.require :default
Dotenv.load

def dataset_download_link(id, format)
  return "https://#{ENV["SOCRATA_CATALOG"]}/api/views/" + id + "/rows." + format + "?accessType=DOWNLOAD"
end

DATASETS="https://#{ENV["SOCRATA_CATALOG"]}/views.json"
ARCHIVE_DIR=ENV["ARCHIVE_DIR"]
  
FileUtils.mkdir_p(ARCHIVE_DIR)

datasets = JSON.parse( RestClient.get(DATASETS) )

#Use the MANIFEST to identify whether datasets have changed: include modification dates (rowsUpdatedAt)
CSV.open( File.join( ARCHIVE_DIR , "MANIFEST" ) , "w" ) do |manifest|
  datasets[1..2].each do |dataset|
    manifest << [ dataset["id"], dataset["name"] ]
    #TODO CSV may not always be the best format
    bundle_url = dataset_download_link( dataset["id"], "csv" )
    agent = Mechanize.new
    agent.pluggable_parser.default = Mechanize::Download
    csv_file = File.join( ARCHIVE_DIR, "#{dataset["id"]}.csv" )
    agent.get(bundle_url).save!( csv_file )  
      
    zipfile_name = File.join( ARCHIVE_DIR, "#{dataset["id"]}.zip" )
    #build the zip even if the entry exists
    Zip.continue_on_exists_proc = true
    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      zipfile.add( "#{dataset["id"]}.csv", File.join( ARCHIVE_DIR, "#{dataset["id"]}.csv" ) )
      metadata = RestClient.get "https://#{ENV["SOCRATA_CATALOG"]}/views/#{dataset["id"]}.json"
      #TODO build datapackage.json
      zipfile.get_output_stream("#{dataset["id"]}.json") { |os| os.write metadata }
    end    
  end
end

