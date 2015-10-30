require "thread"
require "webrick"
require "launchy"
require "contentful_bootstrap/constants"
require "contentful_bootstrap/token"

module ContentfulBootstrap
  class OAuthEchoView
    def render
      <<-JS
      <html><head></head><body>
      <script type="text/javascript">
        (function() {
          var access_token = window.location.hash.split('&')[0].split('=')[1];
          window.location.replace('http://localhost:5123/save_token?token=' + access_token);
        })();
      </script>
      </body></html>
      JS
    end
  end

  class ThanksView
    def render
      <<-HTML
      <html><head>
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css" />
      </head><body>
        <div class="container">
          <div class="jumbotron">
            <h1>Contentful Bootstrap</h1>
            <h4>Thanks! The OAuth Token has been generated</h4>
            <p>The Space you specified will now start to create. You can close this window freely</p>
          </div>
        </div>
      </body></html>
      HTML
    end
  end

  class IndexController < WEBrick::HTTPServlet::AbstractServlet
    def do_GET(request, response)
      client_id = ContentfulBootstrap::Constants::OAUTH_APP_ID
      redirect_uri = ContentfulBootstrap::Constants::OAUTH_CALLBACK_URL
      scope = "content_management_manage"
      Launchy.open("https://be.contentful.com/oauth/authorize?response_type=token&client_id=#{client_id}&redirect_uri=#{redirect_uri}&scope=#{scope}")
      response.status = 200
      response.body = ""
    end
  end

  class OAuthCallbackController < WEBrick::HTTPServlet::AbstractServlet
    def do_GET(request, response)
      response.status = 200
      response.content_type = "text/html"
      response.body = OAuthEchoView.new.render
    end
  end

  class SaveTokenController < WEBrick::HTTPServlet::AbstractServlet
    def do_GET(request, response)
      Token.write(request.query["token"])
      response.status = 200
      response.content_type = "text/html"
      response.body = ThanksView.new.render
    end
  end

  class Server
    attr_reader :server
    def initialize
      @server = WEBrick::HTTPServer.new(:Port => 5123)
      @server.mount "/", IndexController
      @server.mount "/oauth_callback", OAuthCallbackController
      @server.mount "/save_token", SaveTokenController
    end

    def start
      Thread.new { @server.start }
    end

    def stop
      @server.shutdown
    end

    def running?
      @server.status != :Stop
    end
  end
end
