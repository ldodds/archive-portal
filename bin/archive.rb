require 'rubygems'
require 'bundler'
require 'csv'
require 'zip'

$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require "archive-portal"

Bundler.require :default
Dotenv.load

CATALOG="https://#{ENV["SOCRATA_CATALOG"]}"
ARCHIVE_DIR=ENV["ARCHIVE_DIR"]
  
FileUtils.mkdir_p(ARCHIVE_DIR)

catalog = ArchivePortal::Catalog.from_url(CATALOG)

datasets = catalog.datasets

#Use the MANIFEST to identify whether datasets have changed: include modification dates (rowsUpdatedAt)
CSV.open( File.join( ARCHIVE_DIR , "MANIFEST" ) , "w" ) do |manifest|
  
  datasets[1..2].each do |dataset|
    #TODO should be in catalog impl?
    manifest << [ dataset["id"], dataset["name"] ]
      
    dataset_files = catalog.fetch_dataset_files(ARCHIVE_DIR, dataset)
            
    zipfile_name = File.join( ARCHIVE_DIR, "#{dataset["id"]}.zip" )    
    #build the zip even if the entry exists
    Zip.continue_on_exists_proc = true
        
    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|      
      dataset_files.each do |file|
        zipfile.add( File.basename(file), file )
      end
      metadata = catalog.dataset_metadata(dataset)
      #TODO build datapackage.json
      zipfile.get_output_stream("#{dataset["id"]}.json") { |os| os.write metadata.to_json }
    end    
  end
end

