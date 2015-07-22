=begin
This class perform the mapping from OAI requests to Blacklight searches
The code is borrowed from the blacklight_oai_provider gem ()https://github.com/cbeer/blacklight_oai_provider) and modified to the latest version of ruby-oai an Blacklight 5
TODO: commit this code back to the blacklight_oai gem
note: that we add :restrict_to_work to the search_params_logic, so that only documents with cat_ssi:work, is included in the OAI provider
=end
class AdlDocumentWrapper < ::OAI::Provider::Model

  def initialize(controller)
    super(25,'timestamp')
    @controller = controller
  end

  def sets
  end

  def earliest
    Time.parse @controller.search_results({:action=> 'index', :fl => @timestamp_field, :sort => @timestamp_field +' asc', :rows => 1},@controller.search_params_logic + [:restrict_to_works]).last.first.get(@timestamp_field)
  end

  def latest
   Time.parse @controller.search_results({:action=> 'index', :fl => @timestamp_field, :sort => @timestamp_field +' asc', :rows => 1},@controller.search_params_logic + [:restrict_to_works]).last.first.get(@timestamp_field)
  end

  def find(selector, options={})
    return next_set(options[:resumption_token]) if options[:resumption_token]

    if :all == selector
      response, records  = @controller.search_results({:action=> 'index',:sort => @timestamp_field + ' asc', :rows => @limit},@controller.search_params_logic + [:restrict_to_works])

      if @limit && response.total >= @limit
        return select_partial(OAI::Provider::ResumptionToken.new(options.merge({:last => 0})))
      end
    else
      response = @controller.fetch selector.split('/', 2).last
    end
    records
  end

  def select_partial token
    records = @controller.search_results({:action=> 'index', :sort => @timestamp_field + ' asc', :rows => @limit, :page => token.last/@limit + 1},@controller.search_params_logic + [:restrict_to_works]).last

    raise ::OAI::ResumptionTokenException.new unless records

    OAI::Provider::PartialResult.new(records, token.next(token.last+@limit))
  end

  def next_set(token_string)
    raise ::OAI::ResumptionTokenException.new unless @limit

    token = OAI::Provider::ResumptionToken.parse(token_string)
    select_partial(token)
  end

end