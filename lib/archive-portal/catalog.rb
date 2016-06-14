module ArchivePortal
  
  class Catalog
    
    attr_reader :url
    
    def initialize(url)
      @url = url
    end
    
    def self.from_url(url)
      return ArchivePortal::Socrata.new(url)
    end
    
    def datasets
      raise "Not Implemented"
    end
    
    def dataset_metadata(id)
      raise "Not Implemented"
    end
    
    def fetch_dataset_files(id)
      raise "Not Implemented"
    end
    
    def dataset_to_package(id)
      raise "Not Implemented"
    end
    
  end
end