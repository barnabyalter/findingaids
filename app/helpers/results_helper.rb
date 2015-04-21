module ResultsHelper

  ##
  # Render field value, and join as string if it's an array
  def render_field_item(doc)
    doc[:document][doc[:field]].join(", ").truncate(450).html_safe
 end


  ##
  # Render clean faceted link to items in series
  def render_series_facet_link(doc)
    series = doc[:document][Solrizer.solr_name("parent_unittitles", :displayable)]

    coll = doc[:document][Solrizer.solr_name("collection", :displayable)].first

    item_title = doc[:document][Solrizer.solr_name("unittitle", :displayable)][0]

    title = content_tag(:span,item_title, class: "result_ut")
    coll_link = link_to(coll,add_clean_facet_params_and_redirect([collection_facet, coll]))
    links_to_series = []
    series.each do |ser|
      links_to_series << link_to(ser, add_clean_facet_params_and_redirect([series_facet, ser],[collection_facet, coll]))
    end unless doc[:document][Solrizer.solr_name("parent_unittitles", :displayable)].nil? # if there is no series info at all

    [coll_link,links_to_series,title].reject(&:blank?).join(" >> ").html_safe
  end

  ##
  # Helper function to determine if collection
  def is_collection?(field_config, doc)
    doc.is_archival_collection?
  end

  def render_repository_facet_link(doc)
    repository_label repositories.find{|key,hash| hash["admin_code"] == doc}[1]["url"]
  end

  # This is a bit of a hack to work around the fact that we don't want to change repo names
  # in the source repository folder hierarchy. Since folder names match admin_codes,
  # this looks up the looks up the repo by admin_code and grabs the URL.
  def render_repository_link(doc)
    repos_id = Solrizer.solr_name("repository", :stored_sortable)
    if doc.is_a?(Hash) && doc[:document].present? && doc[:document][repos_id].present?
      link_to_repository repositories.find{|key,hash| hash["admin_code"] == doc[:document][repos_id]}[1]["url"]
    end
  end

  ##
  # Render clean link to components
  def render_components_facet_link(doc)
    unless doc[Solrizer.solr_name("collection", :displayable)].blank?
      add_clean_facet_params_and_redirect([collection_facet, doc[Solrizer.solr_name("collection", :displayable)].first])
    end
  end

  ##
  # Render clean link to components for series
  def render_components_for_series_facet_link(doc)
    collection = doc[Solrizer.solr_name("collection", :displayable)].first
    title = doc[Solrizer.solr_name("unittitle", :displayable)].first

    add_clean_facet_params_and_redirect([series_facet, title],[collection_facet, collection])
  end

  ##
  # Render clean facet link to just guide
  def render_collection_facet_link(doc)
    if  doc[:document].is_archival_collection?
      item = doc[:document][doc[:field]].first
      local_params = add_clean_facet_params_and_redirect([collection_facet, item],[format_facet,"Archival Collection"])
      link_to t('search.brief_results.link_text.collection'), local_params, :class => "search_within"
    else
      item = []
      item << content_tag(:span,t('search.brief_results.link_text.other'),class:"search_within")
      item.join("").html_safe
    end
  end

  ##
  # Link to page from table of contents if that field has been indexed and has results
  # This is the only way to ensure that the FA has that page in it
  def link_to_toc_page(doc, label, field)
    content_tag(:dd, link_to(label, url_for_findingaid(doc[:repository_ssi], doc[:ead_ssi], (field == "abstract") ? nil : field), {:target => "_blank"})) if field_has_results_in_document?(doc, field)
  end

  ##
  # Find out if the field exists in the returned solr document
  # If this is one of several fields (i.e. admininfo, abstract, dsc) check a handful of subfields which are the items indexed
  # If field is not explicitly defined in LINK_FIELDS hash, then it's legit so just say true
  def field_has_results_in_document?(doc, field)
    if Findingaids::Ead::Behaviors::LINK_FIELDS.has_key?(field.to_sym)
      Findingaids::Ead::Behaviors::LINK_FIELDS[field.to_sym].any? {|fname| doc[Solrizer.solr_name(fname,:displayable)].present? }
    else
      true
    end
  end


  # Get icon from format type
  def document_icon(doc)
    doc.normalized_format
  end

  def link_to_repository(repository)
    link_to repository_label(repository), send("#{repository}_path")
  end

  def repository_label(repository)
    repositories[repository]["display"]
  end

  def sanitize(html)
    Sanitize.clean(html)
  end

  ##
  # Implement blacklight function to add facet parameters into array for redirect
  # but accept array for multiple facets at a time
  def add_clean_facet_params_and_redirect(*fields)
    new_params = reset_facet_params(params)

    fields.each do |field, item|
      new_params = add_facet_params(field, item, new_params)
    end

    # Delete page, if needed.
    new_params.delete(:page)

    # Delete any request params from facet-specific action, needed
    # to redir to index action properly.
    Blacklight::Solr::FacetPaginator.request_keys.values.each do |paginator_key|
      new_params.delete(paginator_key)
    end
    new_params.delete(:id)

    # Force action to be index.
    new_params[:action] = "index"
    new_params[:controller] = "catalog"
    new_params
  end

  def collection_facet
    @collection_facet ||= facet_name("collection")
  end

  def format_facet
    @format_facet ||= facet_name("format")
  end

  def series_facet
    @series_facet ||= facet_name("series")
  end

  ##
  # Get solrized name from field
  def facet_name(field)
    Solrizer.solr_name(field, :facetable)
  end

  ##
  # Reset facet parameters to clean search
  def reset_facet_params(source_params)
    reset_search_params(source_params.except(:f))
  end

end