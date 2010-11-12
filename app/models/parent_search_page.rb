class ParentSearchPage < Page
  def render
    # response.redirect "/", 302
  end

  def response_code
    response.status
  end
end
