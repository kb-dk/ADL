/**
 * Created by romc on 7/8/15.
 */

window.onresize = function(event) {
    resizeDiv();
}

function resizeDiv() {
    vpw = $(window).width();
    vph = $(window).height() - 108;
    $('.tab-pane').css({'height': vph + 'px'});
    ADL.recalculatePageTopPositions();
}


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

    // generic function to allow buttons with data-function="toggle" to
    // show and hide elements defined in their data-target attribute
    $('[data-function="toggle"]').click(function(){
        var $target = $($(this).data('target'));
        $target.toggle();
        return false;
    });
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
                highlighting = data.response.highlighting;
                $(target_selector).append('<div id="results-header"><p>'+data.response.pages.total_count+' Matches</p></div>');
                for (i in docs) {
                    $(target_selector).append('<p><a href="'+extractDivId(docs[i].id)+'">'+highlighting[docs[i].id].text_tesim.join("...")+'</a></br>Side: '+docs[i].page_ssi+'</p>');
                }
            }

        });
       return false;
    });



    /*
     * Get the query from the 'back to search' link and trigger an  automatic document search
     * with that query
     */
    var q= $("div.search-widgets a[id!='startoverlink']").attr('href');
    if (q) {
        regexp = new RegExp("[?|&]q=([^&;]+?)(&|#|;|$)");
        result = regexp.exec(q);
        q = decodeURIComponent(result[1]).replace('+',' ');
    }
    if (q!= null && q != '') {
        $("#wq").val(q);
        $("#worksearch_btn").click();
    }

    // --- private helper functions ---

    var getHeightOfFixedHeaders = function () {
        var fixedHeaders = $('.fixed, .navbar-fixed-top'),
            allFixedHeaderHeight = 0;
        $.each(fixedHeaders, function (index, fixedHeader) {
            allFixedHeaderHeight += $(fixedHeader).height();
        });
        return allFixedHeaderHeight;
    }

    var getPagePositions = function () {
        var allFixedHeaderHeight = getHeightOfFixedHeaders();
        return $('.pageBreak, .snippetRoot').map(function (index, pageBreakElem) {
            pageBreakElem = (pageBreakElem.id) ? pageBreakElem : $(pageBreakElem).parent()[0]; // FIXME: This would not be needed if Sigge also id tagged pageBreaks on faksimili pages!
            return {
                page: $(pageBreakElem).attr('id').substr(1),
                topPos: $(pageBreakElem).position().top,
                topPosFixed: $(pageBreakElem).position().top + allFixedHeaderHeight - 50, // magic number 50 is to give it a little margin. If the first page only have a few pixels showing, the reader IS on the next page!
                elem: pageBreakElem
            }
        });
    };

    // FIXME: We should wrap all our functions into this object, in order not to polute the global object!
    window.ADL = function (window, $, undefined) {
        return {
            youAreHere: 0,

            PAGETOPPOSITIONS: getPagePositions(), // This is going to be recalculated in ½ sec. but there has to be some values for the first page calculations!

//            getPagePositions: getPagePositions, // We need to recalculate all page positions after the initial load, because they get outdated after a while

            recalculatePageTopPositions: function () {
                this.PAGETOPPOSITIONS = getPagePositions();
            },

            /**
             * Get the page number of the first visible page (or the pagebreak element itself)
             * @param getElem {boolean} Optional If set the method returns the HTMLElement of the pagebreak, else it returns the pagenumber
             * @returns {number | HTMLElement}
             */
            getPageNumber: function(getElem) { // XXX XXX XXX This is the one that actually works!
                // noget med document.offset.y eller noget, og sammenligne det med PAGETOPPOSITIONS
                var scrollTop = $(window).scrollTop();
//                ADL.youAreHere = (scrollTop > 55) ? scrollTop - 18 : scrollTop; // magic number 188 = correcting for fixed headers 50 + 32 + 106 (-110 for only gd know why :( )
                ADL.youAreHere = scrollTop + 198; // magic number 188 = correcting for fixed headers 50 + 32 + 106 (-110 for only gd know why :( ) // XXX XXX FIXME: is 198 necessary here??
                var firstVisiblePage = 1,
                    i = 0;
                while(ADL.youAreHere > ADL.PAGETOPPOSITIONS[i].topPosFixed) {
                    if (i === ADL.PAGETOPPOSITIONS.length - 1) {
                        return getElem ? ADL.PAGETOPPOSITIONS[i].elem : ADL.PAGETOPPOSITIONS[i].page;
                    }
                    i += 1;
                }
                i = (i === 0) ? i : i - 1; // The first visible page is the page before youAreHere > ADL.PAGETOPPOSITIONS[i].topPos
                return getElem ? ADL.PAGETOPPOSITIONS[i].elem : ADL.PAGETOPPOSITIONS[i].page;
            },

            /**
             * Get id of the top most visible text element, used in bookmarking. This method operates on all kind of elements div/p/span/em etc.
             * @return {String/id} Id of the text element in top of the visible part of the viewport.
             */
            getFirstVisibleElement: function () {
                var firstVisibleElement;
                $('*[id^="idm"]').each(function (index, elem) {
                    if ($(elem).visible()) {
                        firstVisibleElement = elem;
                        return false;
                    }
                    return true;
                });
                return firstVisibleElement;
            },

            getCurrentPageId: function () {
                return $(this.getPageNumber(true)).attr('id');
            },

            // TODO: We could work the getFirstVisbleElement out of the equation, and use our own pageTopPositions, but for now I'm just gonna keep it in here /HAFE
            getFirstVisiblePage: function () {
                var firstVisibleElement = this.getFirstVisibleElement();
                if (firstVisibleElement.tagName === 'P' || firstVisibleElement.tagName === 'DIV') {
                    return $(firstVisibleElement);
                } else {
                    return $(firstVisibleElement).closest("div[id^='idm'], p[id^='idm']");
                }
            },

            getFirstVisiblePageId: function () {
                return this.getFirstVisiblePage().attr('id');
            },

            getFirstVisibleId: function () {
                var firstElement = this.getFirstVisibleElement();
                return firstElement ? firstElement.id : '';
            },

            getFirstVisibleText: function () {
                var firstElement = this.getFirstVisibleElement();
                if (firstElement) {
                    if (firstElement.tagName === 'BR') {
                        return firstElement.previousSibling
                    } else {
                        return $(firstElement).text();
                    }
                }
                return '';
            },

            /* // FIXME: This shall be incommented if bookmarks should be per paragraph
            updateBookmarkLink: function (e) {
                // TODO: Somewhere here we need to manipulate the bookmark elements between set and unset!
                var formElem = $('form.bookmark_toggle'),
                    firstVisibleId = ADL.getFirstVisibleId();
                if (firstVisibleId.length) {
                    // There is a line id - append it to the bookmark id
                    formElem.attr('data-firstVisibleIdm', firstVisibleId);
                } else {
                    // No line id - set the bookmark to the entire work
                    formElem.attr('data-firstVisibleIdm', '');
                }
            },
            */

            scrollSniffer: function (e) {
                // ADL.updateBookmarkLink(e); // FIXME: This shall be incommented if bookmarks should be per paragraph

                // FIXME: Set a class instead, and let the stylesheets do the CSS work!
                if ($(window).scrollTop() >= 55) {
                    $('.workContent').addClass('fixedHeader');
                    $('.workHeader dl').hide();
                    $('.workNavbarFixContainer, .workHeaderFixContainer, .nav-tab-instance-fixContainer').addClass('fixed');
                    //correct top for all content (to correct top point just under the fixed top bars)
                    $('#content .workContent div, #content .workContent p').removeClass('top1cor').addClass('top2cor');

                } else {
                    $('.workNavbarFixContainer, .workHeaderFixContainer, .nav-tab-instance-fixContainer').removeClass('fixed');
                    $('.workContent').removeClass('fixedHeader');
                    $('.workHeader dl').show();
                    //correct top for all content (to correct top point just under the fixed top bars)
                    $('#content .workContent div, #content .workContent p').removeClass('top2cor').addClass('top1cor');

                }
            },

            goto: function (idm) {
                var elem = $('#' + idm);
                if (elem.length > 0) {
                    document.body.scrollTop = elem.offset().top;
                    return true;
                }
                return false;
            }
        };
    } (window, jQuery);

    resizeDiv();

    $(document).ajaxComplete(function (e, xhr, options) {
        if (options && options.url && options.url.indexOf('/feedback?') >= 0) { // FIXME: Is this really the best way to pick out the feedback responses?
            // this is a feedback request
            var firstVisiblePageId = ADL.getFirstVisiblePageId();
            if (firstVisiblePageId) { // If there is an id, append it to the errormessage
                var lines = $('#report')[0].value.split(/\n/i);
                $.each(lines, function (index, line) {
                    if (line.indexOf('URL') === 0) {
                        line = line.replace('#','%23'); // html encode the # before workId in the link
                        lines[index] = line + '#' + firstVisiblePageId;
                        return false;
                    }
                });
                $('#report')[0].value = lines.join('\n');
            }
        }
    });

    // setup scrollsniffer
    $(window).scroll(ADL.scrollSniffer);
    // also test the scrollTop from loading (if the page starts scrolled)
    ADL.scrollSniffer();

    // clicks on nav-tab-instance should correct for scrolling page!
    $('.nav-tab-instance').click(function (e) {
        var pageId = ADL.getCurrentPageId();
        if (pageId && e.target.tagName === 'A') {
            $(e.target).attr('href', $(e.target).attr('href') + '/#' + pageId);
        }
    });
    // modal should be closed as soon as one clicks on a in-page link.
    $('.modal-body').click(function (e) {
        if (e.target.tagName === 'A' && ((e.target.href.indexOf('#idm') > 0) || (e.target.href.indexOf('#workid') > 0))) {
            $($(e.target).closest('.modal')).modal('hide');
        }
    });

    // Some of our modal dialogs are nested in bars that get fixed. They all should be mounted directly to body.
    $('.modal').appendTo($('body'));

    setTimeout(function () { ADL.PAGETOPPOSITIONS = getPagePositions(); }, 500); // recalculate pageBreak table a couple of times because they changes after a while
    setTimeout(function () { ADL.PAGETOPPOSITIONS = getPagePositions(); }, 1000);// and it differs a bit from browser to browser how long it takes to have the right numbers
    setTimeout(function () { ADL.PAGETOPPOSITIONS = getPagePositions(); }, 2000);
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

function index_work_search(workid, target_selector, text_label_id){
    workid = encodeURIComponent(workid);
    qselector = $('#q.search_q.q.form-control');
    q = encodeURIComponent($(qselector).val());
    if (!q.trim()){
        $(text_label_id).hide();
    }else{
        $.ajax({
            type: 'GET',
            url: '/catalog.json?search_field=leaf&rows=200&sort=position_isi+asc&q='+q+'&workid='+workid,
            datatype: 'json',
            success: function(data) {
                $(target_selector).empty();
                docs = data.response.docs
                highlighting = data.response.highlighting;
                matches_num = data.response.pages.total_count;
                if (matches_num>0) {
                    $(target_selector).append('<div id="results-header"><p>'+matches_num+' Matches</p></div>');
                    for (var i= 0; i in docs && i<3; i++) {
                        $(target_selector).append('<p><a href="/catalog/'+workid+extractDivId(docs[i].id)+'">'+highlighting[docs[i].id].text_tesim.join("...")+'</a></br>Side: '+docs[i].page_ssi+'</p>');
                    }
                }else{$(text_label_id).hide();}
            }
        });
    }
    return false;
}

