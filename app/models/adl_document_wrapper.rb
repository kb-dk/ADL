=begin
This class perform the mapping from OAI requests to blacklight searches
The code is borrowed from the blacklight_oai_provider gem ()https://github.com/cbeer/blacklight_oai_provider) and modified to the latest version of ruby-oai an blacklight 5
TODO: commit this code back to the blacklight_oai gem
note: that we add :restrict_to_work to the search_params_logic, so that only documents with cat_ssi:work, is included in the OAI provider
=end
require 'time'
class AdlDocumentWrapper < ::OAI::Provider::Model

  def initialize(controller)
    super(25,'timestamp')
    @controller = controller
  end

  def sets
  end

  def earliest
    Time.parse @controller.search_results({:search_field => 'oai_time', :sort => @timestamp_field +' asc', :rows => 1}).last.first[@timestamp_field]
  end

  def latest
    Time.parse @controller.search_results({:search_field => 'oai_time', :sort => @timestamp_field +' desc', :rows => 1}).last.first[@timestamp_field]
  end

  def find(selector, options={})
    return next_set(options[:resumption_token]) if options[:resumption_token]

    if :all == selector
      response, records  = @controller.search_results({:search_field => 'oai_search',:sort => @timestamp_field + ' asc', :rows => @limit, :from => options[:from].utc.iso8601, :until => options[:until].utc.iso8601})

      if @limit && response.total > @limit
        return select_partial(OAI::Provider::ResumptionToken.new(options.merge({:last => 0})))
      end
    else
      response = @controller.fetch selector.split('/', 2).last
    end
    records
  end

  def select_partial token
    response, records = @controller.search_results({:search_field => 'oai_search', :sort => @timestamp_field + ' asc', :rows => @limit, :from => token.from.utc.iso8601, :until => token.until.utc.iso8601, :page => token.last/@limit + 1})

    raise ::OAI::ResumptionTokenException.new unless records

    if @limit && response.total > token.last + @limit
      OAI::Provider::PartialResult.new(records, token.next(token.last+@limit))
    else
      records
    end
  end

  def next_set(token_string)
    raise ::OAI::ResumptionTokenException.new unless @limit

    token = OAI::Provider::ResumptionToken.parse(token_string)
    select_partial(token)
  end

end