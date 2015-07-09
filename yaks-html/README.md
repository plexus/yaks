A HTML output format for Yaks.

Browse your hypermedia API like a good old fashioned web site.

You can see an example output at
[https://myticketsireland.ticketsolve.com/api/](https://myticketsireland.ticketsolve.com/api/)
(visit the [front page](https://myticketsireland.ticketsolve.com/)
first to make sure you have some necessary cookies).

For APIs that make good use of links and forms this provides a great
help during development. It also makes it possible to write
integration tests against the HTML output using Capybara.

We currently provide a small DSL and RSpec integration to make this easy. For example:

```
require 'yaks-html/rspec'

RSpec.describe Yaks::Format::HTML, type: :yaks_integration do
  before do
    Capybara.app = YourRackApp
  end

  let(:rel_prefix) { 'http://myapi.example.com/rel/' }

  it 'should allow browsing the api' do
    visit '/'

    click_rel('friends') # => clicks http://myapi.example.com/rel/friends

    expect(current_path).to eql '/friends'

    expect(page).to have_content 'Matt'

    submit_form(:poke) do
      fill_in :message, with: 'Would you fancy some tea?'
    end

    expect(current_path).to eql '/poke/Matt'

    expect(page).to have_content 'You poked Matt: Would you fancy some tea?'
  end
end
```
