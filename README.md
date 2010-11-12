# Radiant Globalized Search extension

Supports the Globalize2 extension for Radiant.

## Requirements:
  None

## Installation:

This extension works by creating a new page type called "Search".  After you 
install it and re-start your web server, you should have a new type of page 
available.

1) Download and install just like any other extension.
2) Create a new page called "Search" (or whatever you want)
3) Set the Page Type to "Search" and the Status to "Published"
4) Take the sample code below and paste it into the body of the new page.
5) Visit http://localhost:3000/search and enter a search term.
6) Bask in the glow of a job well done.  :)

## Example:
Place everything between the SNIPs in the body of the "Search" page.  This 
will provide a very basic Search page, but it should show you everything you
need to know to make your own page better.

``<r:search:form submit="Search"/>

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
  <li><r:link_or_parent/><br/>
      <r:search:highlight><r:content/></r:search:highlight></li>
  </r:search:results:each>
  </ul>
</r:search:results>``