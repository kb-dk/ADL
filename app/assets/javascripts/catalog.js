/**
 * Created by romc on 7/8/15.
 */
$(document).ready(function(){
    /**
     * Handle search type pseudo facets
     * Set search type to value of clicked facet.
     * If we are already making a search, trigger
     * a new search, otherwise stay on the same page.
     */
    $('a[data-search-type]').click(function(event) {
        event.preventDefault();
        var type = $(this).data('search-type');
        if (typeof type !== 'undefined') {
            $('#search_field').val(type);
            var parser = document.createElement('a');
            parser.href = window.location.href;
            if (parser.search.length > 0) {
                $('#search').click();
            }
        }
        return false;
    });

    /**
     * Terrible hack here - sending empty queries causes
     * some problem with the function query which crashes Solr
     * If we have clicked the search button without a value, enter a space
     */
    $('button#search').click(function(){
        var $input = $('input#q');
        if ($input.val().length == 0) {
            $input.val(' ');
        }
        return true;
    });

    $('input#q').click(function(){
        if ($(this).val() == ' ') {
            $(this).val('')
        }
    })


});

//Change the label fo the collapse buttons in the search results page
function changeButtonLabel(elem){
    if (elem.innerHTML.trim()=="Vis mere") elem.innerHTML = "Vis mindre";
    else elem.innerHTML = "Vis mere"
}