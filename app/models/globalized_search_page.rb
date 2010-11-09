class GlobalizedSearchPage < Page
  description "Provides tags and behavior to support searching Radiant.  Based on Oliver Baltzer's search_behavior."
  attr_accessor :query_result, :query
  #### Tags ####
   
  desc %{    Renders the passed query.}
  tag 'search:query' do |tag|
    CGI.escapeHTML(query)
  end
  
  desc %{   Renders the contained block when query is blank.}
  tag 'search:initial' do |tag|
    if query.empty?
      tag.expand
    end
  end
 
  desc %{   Renders the contained block if no results were returned.}
  tag 'search:empty' do |tag|
    if query_result.blank? && !query.empty?
      tag.expand
    end
  end
  
  desc %{    Renders the contained block if results were returned.}
  tag 'search:results' do |tag|
    unless query_result.blank?
      tag.expand
    end
  end

  desc %{    Renders the contained block for each result page.  The context
    inside the tag refers to the found page.}
  tag 'search:results:each' do |tag|
    returning String.new do |content|
      query_result.each do |page|
        radiant_page = Page.find(page.page_id)
        tag.locals.page = radiant_page
        content << tag.expand
      end
    end
  end

  desc %{    Quantity of search results fetched.}
  tag 'search:results:quantity' do |tag|
    query_result.blank? ? 0 : query_result.size
  end

  desc %{    <r:truncate_and_strip [length="100"] />
    Truncates and strips all HTML tags from the content of the contained block.  
    Useful for displaying a snippet of a found page.  The optional `length' attribute
    specifies how many characters to truncate to.}
  tag 'truncate_and_strip' do |tag|
    tag.attr['length'] ||= 100
    length = tag.attr['length'].to_i
    helper.truncate(helper.strip_tags(tag.expand).gsub(/\s+/," "), length)
  end
  
  desc %{    <r:search:highlight [length="100"] />
    Highlights the search keywords from the content of the contained block.
    Strips all HTML tags and truncates the relevant part.      
    Useful for displaying a snippet of a found page.  The optional `length' attribute
    specifies how many characters to truncate to.}
  tag 'highlight' do |tag|    
    length = (tag.attr['length'] ||= 15).to_i
    content = helper.strip_tags(tag.expand).gsub(/\s+/," ")
    relevant_content = content.split[0..(length - 1)].join(' ') + (content.split.size > length ? "..." : '')
    helper.highlight(relevant_content, query.split) 
  end  
  
  #### "Behavior" methods ####
  def cache?
    false
  end
  
  def render
    @query_result = []
    @query = ""
    q = @request.parameters[:q]
    case Page.connection.adapter_name.downcase
    when 'postgresql'
      sql_content_check = "((lower(page_parts.content) LIKE ?) OR (lower(title) LIKE ?))"
    else
      sql_content_check = "((LOWER(page_parts.content) LIKE ?) OR (LOWER(title) LIKE ?))"
    end
    unless (@query = q.to_s.strip).blank?
      pages = Page.find_by_sql("SELECT pages.id AS page_id, pages.class_name, pages.status_id, pages.parent_id, pages.virtual, pages.position, pages.sitemap FROM `pages` LEFT OUTER JOIN `page_parts` ON page_parts.page_id = pages.id LEFT OUTER JOIN `page_part_translations` ON page_part_translations.page_part_id = page_parts.id WHERE (LOWER(page_part_translations.content) LIKE '%#{q}%') AND page_part_translations.locale = '#{params[:locale]}' AND class_name = '' GROUP BY page_id ORDER BY published_at DESC")
      @query_result = pages.delete_if { |p| !p.published? }
    end
    lazy_initialize_parser_and_context
    if layout
      parse_object(layout)
    else
      render_page_part(:body)
    end
  end
  
  def helper
    @helper ||= ActionView::Base.new
  end
  
end

class Page
  #### Tags ####
  desc %{    The namespace for all search tags.}
  tag 'search' do |tag|
    tag.expand
  end

  desc %{    <r:search:form [label=""] [url="search"] [submit="Search"] />
    Renders a search form, with the optional label, submit text and url.}
  tag 'search:form' do |tag|
    label = tag.attr['label'].nil? ? "" : "<label for=\"q\">#{tag.attr['label']}</label> "
    submit = "<input value=\"#{tag.attr['submit'] || "Search"}\" type=\"submit\" />"
    url = tag.attr['url'].nil? ? self.url.chop : tag.attr['url']
    @query ||= ""    
    content = %{<form action="#{url}" method="get" id="search_form"><p>#{label}<input type="text" id="q" name="q" value="#{CGI.escapeHTML(@query)}" size="15" alt=\"search\"/> #{submit}</p></form>}
    content << "\n"
  end

end
