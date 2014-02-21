module Findingaids::Catman
  extend ActiveSupport::Concern

  include Blacklight::Catalog

  # Adds the solr_name method to the catalog controller
  module ClassMethods
    def solr_name(name, *opts)
      Solrizer.solr_name(name, *opts)
    end
    def qf_fields
      ["title_ssm^2000.0",
      "#{solr_name("collection", :searchable)}^1000.0",
      "#{solr_name("title", :stored_searchable)}^1000.0",
      "#{solr_name("title", :searchable)}^1000.0",
      "#{solr_name("subject", :searchable)}^250.0",
      "#{solr_name("abstract", :searchable)}^250.0" ,
      "#{solr_name("controlaccess", :searchable)}^100.0",
      "#{solr_name("scopecontent", :searchable)}^90.0",
      "#{solr_name("bioghist", :searchable)}^80.0",
      "#{solr_name("unittitle", :searchable)}^70.0",
      "#{solr_name("odd", :searchable)}^60.0",
      "#{solr_name("index", :searchable)}^50.0",
      "#{solr_name("phystech", :searchable)}^40.0",
      "#{solr_name("acqinfo", :searchable)}^30.0",
      "#{solr_name("sponsor", :searchable)}^20.0",
      "#{solr_name("custodhist", :searchable)}^10.0"].join(" ")
    end
    def pf_fields
      qf_fields
    end
    def hl_fields
      ["#{solr_name("collection", :searchable)}",
      "#{solr_name("title", :stored_searchable)}" ,
      "#{solr_name("title", :searchable)}",
      "#{solr_name("subject", :searchable)}",
      "#{solr_name("abstract", :searchable)}",
      "#{solr_name("controlaccess", :searchable)}",
      "#{solr_name("scopecontent", :searchable)}",
      "#{solr_name("bioghist", :searchable)}",
      "#{solr_name("unittitle", :searchable)}",
      "#{solr_name("odd", :searchable)}",
      "#{solr_name("index", :searchable)}",
      "#{solr_name("phystech", :searchable)}",
      "#{solr_name("acqinfo", :searchable)}",
      "#{solr_name("sponsor", :searchable)}",
      "#{solr_name("custodhist", :searchable)}"].join(" ")
    end
  end

end
