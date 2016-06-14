module ArchivePortal
  
  class Socrata < Catalog

    def initialize(url)
      super(url)
    end    
    
    #return array of datasets
    def datasets
      JSON.parse( RestClient.get( "#{@url}/views.json" ) )
    end
    
    def dataset_metadata(dataset)
      JSON.parse( RestClient.get("#{@url}/views/#{dataset["id"]}.json") )
    end
    
    #not just csv
    #return [] of file names?
    def fetch_dataset_files(archive_dir,  dataset)
      datasets = []
      rows_url = "#{@url}/api/views/" + dataset["id"] + "/rows.csv?accessType=DOWNLOAD"
      agent = Mechanize.new
      agent.pluggable_parser.default = Mechanize::Download
      csv_file = File.join( archive_dir, "#{dataset["id"]}.csv" )
      agent.get(rows_url).save!( csv_file )  
      datasets << csv_file
      datasets
    end
    
    def dataset_to_package(id)
      raise "Not Implemented"
    end
    
  end
end