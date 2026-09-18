require "rails_helper"

RSpec.describe "Retired URLs", type: :request do
  it "answers a retired path with its destination" do
    Redirect.create!(from_path: "/old-shop", to_path: "/shop", status_code: 301)

    get "/old-shop"

    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/shop")
  end

  it "honours a temporary redirect as temporary" do
    Redirect.create!(from_path: "/temporarily-here", to_path: "/shop", status_code: 302)

    get "/temporarily-here"

    expect(response).to have_http_status(:found)
  end

  it "stops answering once the redirect is discarded" do
    redirect = Redirect.create!(from_path: "/gone", to_path: "/shop", status_code: 301)
    redirect.discard

    get "/gone"

    expect(response).to have_http_status(:not_found)
  end

  it "leaves every other unknown path to the router" do
    get "/no-such-page"

    expect(response).to have_http_status(:not_found)
  end

  it "does not shadow a live page" do
    get shop_path

    expect(response).to have_http_status(:ok)
  end
end
