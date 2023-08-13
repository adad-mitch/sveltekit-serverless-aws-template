locals {
  # A map of file extensions and their respective MIME types, so they can be
  # appropriately labelled as such in S3.
  content_type_map = {
    "css"   = "text/css"
    "html"  = "text/html"
    "gif"   = "image/gif"
    "jpeg"  = "image/jpeg"
    "jpg"   = "image/jpeg"
    "js"    = "text/javascript"
    "json"  = "application/json"
    "png"   = "image/png"
    "svg"   = "image/svg+xml"
    "webp"  = "image/webp"
    "woff"  = "font/woff"
    "woff2" = "font/woff2"
    "xml"   = "text/xml"
  }
}
