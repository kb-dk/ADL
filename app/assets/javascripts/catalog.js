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


    // Uses jQuery unveil library for lazyloading facsimile images
    $("img").unveil();

    /**
     * Remove the 'leaf' option from search_field options
     */
    $("#search_field option[value='leaf']").remove()

    $("[data-function='worksearch']").click(function(e){
        workid = encodeURIComponent($(this).data('workid'));
        qselector = $(this).data('selector');
        target_selector = $(this).data('target');
        q = encodeURIComponent($(qselector).val());
        $.ajax({
            type: 'GET',
            url: '/catalog.json?search_field=leaf&rows=200&sort=position_isi+asc&q='+q+'&workid='+workid,
            datatype: 'json',
            success: function(data) {
                $(target_selector).empty();
                docs = data.response.docs
                $(target_selector).append('<div id="results-header"><p>'+data.response.pages.total_count+' Matches</p></div>');
                for (i in docs) {
                    $(target_selector).append('<p><a href="'+extractDivId(docs[i].id)+'">'+docs[i].text_tesim+'</a></br>Side: '+docs[i].page_ssi+'</p>');
                }
            }

        });
       return false;
    });

    /*
     * Get the query from the 'back to search' link and trigger an  automatic document search
     * with that query
     */
    var q= getURLParameter($("div.search-widgets a[id!='startoverlink']").attr('href').split('?'),'q');
    if (q!= null && q != '') {
        $("#wq").val(q);
        $("#worksearch_btn").click();
    }


});

function cookieTerms(cname, cvalue, exdays) {
    var d = new Date();
    d.setTime(d.getTime() + (exdays*24*60*60*1000));
    var expires = "expires="+d.toUTCString();
    document.cookie = cname + "=" + cvalue + "; " + expires;
}

function getCookie(cname) {
    var name = cname + "=";
    var ca = document.cookie.split(';');
    for(var i=0; i<ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0)==' ') c = c.substring(1);
        if (c.indexOf(name) == 0) return c.substring(name.length,c.length);
    }
    return "";
}

function checkCookie() {
    var cookie = getCookie("terms");
    if (cookie != "") {
//        console.log("cookie: "+ cookie);
//        document.getElementById("cookie-button").style.display="none";
    } else {
        document.getElementById("cookie-button").style.display="block";
        if (cookie != "" && cookie != null) {
            cookieTerms("terms", cookie, 60);
        }
    }
}

//Change the label fo the collapse buttons in the search results page
function changeButtonLabel(elem){
    if (elem.innerHTML.trim()=="Vis mere") elem.innerHTML = "Vis mindre";
    else elem.innerHTML = "Vis mere"
}

function extractDivId(id){
    return id.substr(id.lastIndexOf('#'));
}

function getURLParameter(url,name) {
    return decodeURIComponent((new RegExp('[?|&]' + name + '=' + '([^&;]+?)(&|#|;|$)').exec(url)||[,""])[1].replace(/\+/g, '%20'))||null
}

