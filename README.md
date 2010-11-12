# Radiant Globalized Search extension

Supports the Globalize2 extension for Radiant.

## Requirements:
  [Radiant Globalize2 extension](http://github.com/Aissac/radiant-globalize2-extension)

## Installation:

This extension works by creating a new page type called "Search".  After you 
install it and re-start your web server, you should have a new type of page 
available.

1. Download and install just like any other extension.
2. Create a new page called "Search" (or whatever you want)
3. Set the Page Type to "Search" and the Status to "Published"
4. Take the sample code below and paste it into the body of the new page.
5. Visit http://localhost:3000/search and enter a search term.
6. Bask in the glow of a job well done.  :)

## Additional Page Types

You can use now additional PageTypes like `Parent Search` or `No Search`. All pages with any PageTypes will automatically excluded of the Globalized Search extension. If you now want to exclude a page of the search action simple choose the `No Search` Page Type.
If you have pages which were rendered by the parent with the `r:children:each` tag of Radiant and you don't want to show this site but the parent site simple use the `Parent Search` tag.

## Example:
Place everything of the following code in the body of the "Search" page.  This 
will provide a very basic Search page, but it should show you everything you
need to know to make your own page better.

    <r:search:form submit="Search"/>

    <r:search:initial>
      <strong>Enter a phrase above to search this website.</strong>
    </r:search:initial>

    <r:search:empty>
      <strong>I couldn't find anything named "<r:search:query/>".</strong>
    </r:search:empty>

    <r:search:results>
      Found the following pages that contain "<r:search:query/>".

      <ul>
        <r:search:results:each>
          <li><r:parent_or_self_link/><br/>
          <r:search:highlight><r:content/></r:search:highlight></li>
        </r:search:results:each>
      </ul>
    </r:search:results>
    