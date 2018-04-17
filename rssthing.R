library(xml2)
library(rvest)
library(tidyverse)

doc <- read_xml("https://feeds.feedburner.com/RBloggers")

atom_link <- list(`atom:link`=list())
attr(atom_link$`atom:link`, "xmlns:atom10") <- "http://www.w3.org/2005/Atom"
attr(atom_link$`atom:link`, "rel") <- "self"
attr(atom_link$`atom:link`, "type") <- "application/rss+xml"
attr(atom_link$`atom:link`, "href") <- "http://example.com/"

list(
  rss = list(
    channel = list(
      title = list("R-bloggers Direct"),
      link = list("http://example.com/"),
      description = list("Direct links to R blogs on R-bloggers"), # :-)
      lastBuildDate = list(format(Sys.time(), "%a, %d %b %Y %H:%M:%S %z")),
      language = list("en-US"),
      `sy:updatePeriod` = list("hourly"),
      `sy:updateFrequency` = list("1"),
      generator = list("R")
    )
  )
) -> rss

rss$rss$channel <- c(rss$rss$channel, atom_link[1])

str(rss, 3)

attr(rss$rss, "xmlns:content") <- "http://purl.org/rss/1.0/modules/content/"
attr(rss$rss, "xmlns:wfw") <- "http://wellformedweb.org/CommentAPI/"
attr(rss$rss, "xmlns:dc") <- "http://purl.org/dc/elements/1.1/"
attr(rss$rss, "xmlns:atom") <- "http://www.w3.org/2005/Atom"
attr(rss$rss, "xmlns:sy") <- "http://purl.org/rss/1.0/modules/syndication/"
attr(rss$rss, "xmlns:slash") <- "http://purl.org/rss/1.0/modules/slash/"
attr(rss$rss, "xmlns:feedburner") <- "http://rssnamespace.org/feedburner/ext/1.0"
attr(rss$rss, "version") <- "2.0"

xml_find_all(doc, ".//channel/item") %>%
    map(~{
      list(
        item = list(
          guid = list(xml_find_first(.x, ".//guid") %>% xml_text()), # :-)
          link = list(xml_find_first(.x, ".//guid") %>% xml_text()), # :-)
          title = list(xml_find_first(.x, ".//title") %>% xml_text()),
          pubDate = list(xml_find_first(.x, ".//pubDate") %>% xml_text()),
          `dc:creator` = list(xml_find_first(.x, ".//dc:creator") %>% xml_text()),
          description = list(xml_find_first(.x, ".//description") %>% xml_text()),
          `content:encoded` = list(xml_find_first(.x, ".//description") %>% xml_text())
        )
      )
    }) -> items

for (i in seq_along(items)) {
  rss$rss$channel <- c(rss$rss$channel, items[[i]])
}

str(rss, 3)

rss %>%
  as_xml_document() %>%
  as.character() %>%
  cat()

