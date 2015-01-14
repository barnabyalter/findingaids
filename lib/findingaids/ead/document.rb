class Findingaids::Ead::Document < SolrEad::Document

  include Findingaids::Ead::Behaviors

  use_terminology SolrEad::Document

  extend_terminology do |t|
    t.title(:path=>"archdesc/did/unittitle", :index_as=>[:unstemmed_searchable])
    t.title_num(:path=>"archdesc/did/unitid", :index_as=>[:searchable, :displayable])
    t.abstract(:path=>"archdesc/did/abstract", :index_as=>[:searchable, :displayable])
    t.sponsor(:path=>"sponsor", :index_as=>[:searchable,:displayable])

    # General field available within archdesc
    t.acqinfo(:path=>"archdesc/acqinfo/p", :index_as=>[:searchable, :displayable])
    t.bioghist(:path=>"archdesc/bioghist/p", :index_as=>[:searchable, :displayable])
    t.custodhist(:path=>"archdesc/custodhist/p", :index_as=>[:searchable, :displayable])
    t.phystech(:path=>"archdesc/phystech/p", :index_as=>[:searchable, :displayable])
    t.relatedmaterial(:path=>"archdesc/relatedmaterial/p", :index_as=>[:searchable, :displayable])
    t.controlaccess(:path => "archdesc/controlaccess", :index_as=>[:searchable, :displayable])
    t.scopecontent(:path=>"archdesc/scopecontent/p", :index_as=>[:searchable, :displayable])
    t.index(:path=>"archdesc/index", :index_as=>[:searchable, :displayable])

    # These are component level items indexed into the document as fulltext searchable fields
    # so Blacklight can search it at the top level. Once this simple search is done we can search
    # the components which are individually indexed by solr_ead to get additional info
    #t.unittitle(:path=>"archdesc/dsc//c[@level='file' or @level='item']/did/unittitle", :index_as=>[:searchable, :displayable])
    #t.odd(:path=>"archdesc/dsc//c[@level='file' or @level='item']/odd", :index_as=>[:searchable, :displayable])

    t.title_filing(:path=>"archdesc[@level='collection']/did/unittitle", :index_as=>[:sortable])
    t.date_filing(:path=>"archdesc/unitdate[@type='inclusive']/@normal", :index_as=>[:sortable])

    t.publisher(:path => "publisher", :index_as => [:searchable])
    t.dsc
  end

  def to_solr(solr_doc = Hash.new)
    solr_doc = super(solr_doc)

    solr_doc.merge!(Solrizer.solr_name("repository", :stored_sortable) => format_repository)
    solr_doc.merge!(Solrizer.solr_name("repository", :facetable) => format_repository)

    Solrizer.insert_field(solr_doc, "heading",      heading_display,        :displayable) unless self.title_num.empty?
    Solrizer.insert_field(solr_doc, "format",       "Archival Collection",  :facetable)
    Solrizer.insert_field(solr_doc, "format",       "Archival Collection",  :displayable)
    Solrizer.insert_field(solr_doc, "format",       0,                      :sortable)
    Solrizer.insert_field(solr_doc, "unitdate",     ead_date_display,       :displayable)
    Solrizer.insert_field(solr_doc, "creator",      get_ead_names,          :displayable)
    Solrizer.insert_field(solr_doc, "creator",      get_ead_names,          :facetable)

    Solrizer.set_field(solr_doc, "genre",           self.genreform,              :facetable)
    Solrizer.set_field(solr_doc, "genre",           self.genreform,              :displayable)
    Solrizer.set_field(solr_doc, "subject",         get_ead_subject_facets,      :facetable)
    Solrizer.set_field(solr_doc, "collection",      self.collection.first.strip, :facetable)
    Solrizer.set_field(solr_doc, "collection",      self.collection.first.strip, :displayable)

    # Replace certain fields with their html-formatted equivlents
    Solrizer.set_field(solr_doc, "title", self.term_to_html("title"), :displayable)

    # Set lanuage codes
    solr_doc.merge!(ead_language_fields)

    return solr_doc
  end

  protected
  def heading_display
    "Guide to the " + self.term_to_html("title") + " (" + self.title_num.first + ")"
  end

end
