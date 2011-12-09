module Remotipart
  # Responder used to automagically wrap any non-xml replies in a text-area
  # as expected by iframe-transport.  Additionally, utilizes `postMessage`
  # in order to safely enable corss-origin communication.
  module RenderOverrides
    include ActionView::Helpers::TagHelper

    def render *args
      super
      if remotipart_submitted?
        response.content_type = Mime::HTML
        response.body = %{
          <html>
            <head>
              <script type="text/javascript" charset="utf-8">
                function respond() {
                  parent.postMessage({
                    contextId   : "#{params[:remotipart_context]}" || null,
                    contentType : "#{content_type}",
                    statusCode  : "#{response.response_code}",
                    response    : #{response.body}
                  }, "*");
                }

                respond();
              </script>
            </head>
            <body>
              <textarea data-type=\"#{content_type}\" response-code=\"#{response.response_code}\">#{escape_once(response.body)}</textarea>
            </body>
          </html>
        }
      end
      response_body
    end
  end
end
