# Radiant Globalized Search Extension
This is a Radiant search extension for websites which use the [Globalize2 extension](http://github.com/Aissac/radiant-globalize2-extension).

## Requirements
[Radiant Globalize2 extension](http://github.com/Aissac/radiant-globalize2-extension)

## Installation
This extension works by creating a new page type called "Search". After you install it and re-start your web server, you should have new page types available.

1. Download and install just like any other extension.
2. Create a new page called "Search" (or whatever you want)
3. Set the Page Type to "Globalized Search" and the Status to "Published"
4. Take the sample code below and paste it into the body of the new page.
5. Visit http://localhost:3000/search and enter a search term.
6. Bask in the glow of a job well done.  :)

## Additional Page Types
You can use now additional Page Types like "Parent Search" or "No Search". All pages with any Page Types will be automatically excluded from the search process. If you now want to exclude another normal page from the search process simple choose the "No Search" Page Type.
If you have pages which were rendered by the parent with for example the `r:children:each` tag of Radiant and you don't want to show the child but the parent site simple use the "Parent Search" Page Type. So the search result will be the parent site instead of the child site.

## Example
Place everything of the following code in the body of the "Search" page.  This will provide a very basic Search page, but it should show you everything you need to know to make your own page better.

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