# The errors controller handles our custom error pages. To enable this you add
# config.exceptions_app = self.routes to config/application.rb. What should
# be noted in our case is that switching it off and removing the error routes
# does not then switch us back to rails handling errors. Somewhere in our
# project we have 'broken' this behaviour.
# N.B. All definitions are taken from
# http://en.wikipedia.org/wiki/List_of_HTTP_status_codes
class ErrorsController < ApplicationController
  # Unauthorized
  # Similar to 403 Forbidden, but specifically for use when authentication is
  # required and has failed or has not yet been provided. The response must
  # include a WWW-Authenticate header field containing a challenge applicable
  # to the requested resource. See Basic access authentication and Digest
  # access authentication.
  def client_error_401
    render file: '/public/session_expired.html', status: 401
  end

  # Forbidden
  # The request was a valid request, but the server is refusing to respond to
  # it. Unlike a 401 Unauthorized response, authenticating will make no
  # difference.
  def client_error_403
    render file: '/public/403.html', status: 403
  end

  # Not found
  # The requested resource could not be found but may be available again in the
  # future. Subsequent requests by the client are permissible.
  def client_error_404
    render file: '/public/404.html', status: 404
  end

  # Unprocessable Entity
  # The request was well-formed but was unable to be followed due to semantic
  # errors.
  def client_error_422
    render file: '/public/422.html', status: 422
  end

  # Internal server error
  # A generic error message, given when an unexpected condition was encountered
  # and no more specific message is suitable.
  def server_error_500
    render file: '/public/500.html', status: 500
  end

  # Service Unavailable
  # The server is currently unavailable (because it is overloaded or down for
  # maintenance). Generally, this is a temporary state.
  def server_error_503
    render file: '/public/503.html', status: 503
  end
end
