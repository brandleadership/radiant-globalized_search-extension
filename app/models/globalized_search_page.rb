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
        radiant_page = Page.find(page.id)
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
  
  desc %{ }
  tag 'parent_or_self_link' do |tag|
    text = tag.double? ? tag.expand : tag.render('title')
    slugs = tag.locals.page.ancestors.map {|a| a.slug}.reverse
    slugs[0] = I18n.locale.to_s
    slugs << tag.locals.page.slug unless tag.locals.page.class_name == 'ParentSearchPage'
    %{<a href="/#{slugs.join('/')}">#{text}</a>}
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
      @query_result = Page.find(:all, :conditions => ['page_part_translations.content LIKE ? AND page_part_translations.locale = ? AND status_id = ? AND (class_name = ? OR class_name = ?)', "%#{@query}%", I18n.locale.to_s, (Status[:published]).id, '', 'ParentSearchPage'], :include => [:parts => :translations], :order => 'published_at DESC')
    end
    lazy_initialize_parser_and_context
    layout ? parse_object(layout) : render_page_part(:body)
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
