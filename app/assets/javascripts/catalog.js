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
    setTimeout(ADL.recalculatePageTopPositions, 500); // XXX XXX FIXME: This sucks!
    setTimeout(ADL.recalculatePageTopPositions, 1500);
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


    // generic function to allow buttons with data-function="toggle" to
    // show and hide elements defined in their data-target attribute
    $('[data-function="toggle"]').click(function(){
        var $target = $($(this).data('target'));
        $target.toggle();
        return false;
    });

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
                $(target_selector).append('<div id="results-header"><p>'+data.response.pages.total_count+' match</p></div>');
                for (i in docs) {
                    $(target_selector).append('<p><a href="'+(ADL.pageType === 'text' ? extractDivId(docs[i].id) : '#' + docs[i].page_id_ssi)+'">' + highlighting[docs[i].id].text_tesim.join("...")+'</a></br>Side: '+docs[i].page_ssi+'</p>');
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
            pageId = $(pageBreakElem).attr('id');
            return {
                page: /^s\d+$/.test(pageId) ? pageId.substr(1) : pageId,
                topPos: $(pageBreakElem).position().top,
                topPosFixed: $(pageBreakElem).position().top + allFixedHeaderHeight - 50, // magic number 50 is to give it a little margin. If the first page only have a few pixels showing, the reader IS on the next page!
                elem: pageBreakElem
            }
        });
    };

    // Detect if this is an old IE (FIXME: this sucks, but we are running out of time!)
    var ieVersion = parseInt(navigator.userAgent.split('MSIE')[1],10);

    // FIXME: We should wrap all our functions into this object, in order not to polute the global object!
    window.ADL = function (window, $, undefined) {
        return {
            test : false, // remove this to get rid of all kinds of test outputs (the pagenumber in bottom right so far)!
            youAreHere: 0,

            thisIsAnOldIE: !!ieVersion ? ieVersion < 10 : false,
            PAGETOPPOSITIONS: getPagePositions(), // This is going to be recalculated in ½ sec. but there has to be some values for the first page calculations!

            recalculatePageTopPositions: function () {
                this.PAGETOPPOSITIONS = getPagePositions();
            },

            _ie9SetFixedHeaders: function () {
                $('.workNavbarFixContainer').css({
                    'position': 'fixed',
                    'top': '50px',
                    'right': 0,
                    'left': 0,
                    'background-color': '#fff',
                    'z-index': 10
                });
                $('.workHeaderFixContainer').css({
                    'position': 'fixed',
                    'top': '82px',
                    'right': 0,
                    'left': 0,
                    'background-color': '#fff',
                    'z-index': 10
                });
                $('.nav-tab-instance-fixContainer').css({
                    'position': 'fixed',
                    'top': '147px',
                    'right': 0,
                    'left': 0,
                    'background-color': '#fff',
                    'z-index': 10
                });
            },

            _ie9RemoveFixedHeaders: function () {
                $('.workNavbarFixContainer').css({
                    'position': 'static',
                    'top': 'auto',
                    'right': 'auto',
                    'left': 'auto',
                    'background-color': '#fff',
                    'z-index': 'auto'
                });
                $('.workHeaderFixContainer').css({
                    'position': 'static',
                    'top': 'auto',
                    'right': 'auto',
                    'left': 'auto',
                    'background-color': '#fff',
                    'z-index': 'auto'
                });
                $('.nav-tab-instance-fixContainer').css({
                    'position': 'static',
                    'top': 'auto',
                    'right': 'auto',
                    'left': 'auto',
                    'background-color': '#fff',
                    'z-index': 'auto'
                });
            },

            pageType: (function () {
                var snippetRoot = $('.snippetRoot');
                if (snippetRoot.hasClass('facsimile')) {
                    return 'facsimile';
                }
                if (snippetRoot.hasClass('text')) {
                    return 'text';
                }
                return 'other';
            })(),

            /**
             * Get the page number of the first visible page (or the pagebreak element itself)
             * @param getElem {boolean} Optional If set the method returns the HTMLElement of the pagebreak, else it returns the pagenumber
             * @returns {number | HTMLElement}
             */
            getPageNumber: function(getElem) { // XXX XXX XXX This is the one that actually works!
                if (!ADL.PAGETOPPOSITIONS.length) {
                    return 0; // If there is no pagebreaks just return 0;
                }
                // noget med document.offset.y eller noget, og sammenligne det med PAGETOPPOSITIONS
                var scrollTop = $(window).scrollTop();
                ADL.youAreHere = (scrollTop > 55) ? scrollTop + 88 : scrollTop; // magic number 188 = correcting for fixed headers 50 + 32 + 106 (-100 for only God know why :( )
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

                // Add pagenumber bottom right if test
                if (ADL.test) {
                    var pageNumber = $('.showPage');
                    if (!pageNumber.length) {
                        pageNumber = $('<div class="showPage" style="position:fixed;z-index:100000;background-color:#fff;color:#000;text-align:center;padding-top:8px;height:32px;min-width:32px;bottom:10px;right:10px;border-radius:5px;border:2px solid #000"></div>');
                        pageNumber.appendTo('body');
                    }
                    $('.showPage').text(ADL.getPageNumber());
                }

                var bodyHeightMinusWindowHeight = $('body').height() - $(window).height();
                if ((bodyHeightMinusWindowHeight > 192 ) || $('body').hasClass('fixedHeader') ) { // FIXME: The 192 and 126 magic numbers are heights in the header, and they should be meassured at pageload, instead of just hardcoded!!
                    if ($(window).scrollTop() >= 55) {
                        $('body').addClass('fixedHeader');
                        if (ADL.thisIsAnOldIE) {
                            // Apparently the css does not work in IE9, so now we do the header fixing "by hand" // FIXME: This ought not to be necessary!
                            ADL._ie9SetFixedHeaders();
                        }
                        $('.workHeader dl').slideUp(200); // We have a minor animation to let users subliminal understand that we are collapsing the header
                    } else {
                        $('body').removeClass('fixedHeader');
                        if (ADL.thisIsAnOldIE) {
                            // Apparently the css does not work in IE9, so now we do the header fixing "by hand" // FIXME: This ought not to be necessary!
                            ADL._ie9RemoveFixedHeaders();
                        }
                        $('.workHeader dl').slideDown(200);
                    }
                } else {
                    if ($('body').hasClass('fixedHeader') && bodyHeightMinusWindowHeight < (192 - 126)) { // 188px is the header height 126px is the collapsible header part
                        $('body').removeClass('fixedHeader'); // This is duplicateCode - make a function!
                        if (ADL.thisIsAnOldIE) {
                            // Apparently the css does not work in IE9, so now we do the header fixing "by hand" // FIXME: This ought not to be necessary!
                            ADL._ie9RemoveFixedHeaders();
                        }
                        $('.workHeader dl').slideDown(200);
                    }
                }
            },

            getHeaderHeight: function () {
                return $('.navbar-fixed-top').height() + $('.workNavbarFixContainer').height() + $('.workHeaderFixContainer').height();
            },

            calculateDesiredScrollTop: function () {
                var fragmentId = location.hash;
                if (fragmentId.length) {
                    var elem = $(fragmentId), // NOTE: If we ever will use the fragment identifier to anything else than mere id's, this has got to change!
                        elemTop = elem.length ? elem.position().top : null,
                        headerHeight = ADL.getHeaderHeight();
                    var result = $.isNumeric(elemTop) ? elemTop - headerHeight + 107 : null;
                    result = result < 0 ? 0 : result; // IE breaks on top positions less than zero.
                    return result;
                }
                return; // if there is no fragmentIdentifier, anywhere in the document will be right
            },

            ajustForHeader: function () {
                ADL.recalculatePageTopPositions();
                var supposedToBeAtPos = ADL.calculateDesiredScrollTop();
                if ($('body').hasClass('fixedHeader') && $.isNumeric(supposedToBeAtPos)) {
                    if ($(window).scrollTop() !== supposedToBeAtPos) {
                        $(window).scrollTop(supposedToBeAtPos);
                    }
                }
                return 0;
            },

            goto: function (idm) {
                var elem = $('#' + idm);
                if (elem.length > 0) {
                    document.body.scrollTop = elem.offset().top;
                    return true;
                }
                return false;
            },

            checkAndFixHeaderProblem: function () {
                var idToBeAt = location.hash;
                if (idToBeAt.length) {
                    var elem = $(idToBeAt),
                        elemTop = elem.position().top,
                        scrollTop = $(window).scrollTop(),
                        headerHeight = ADL.getHeaderHeight();
                    $(window).scrollTop(elemTop - 80); // XXX XXX XXX Hvad fanden er det for 80 her? :-O
                }
            },

            console: {
                log: function (msg) {
                    if ('undefined' !== typeof window.console) {
                        window.console.log(msg);
                    }
                }
            }
        };
    } (window, jQuery);

    window.ADL.scrollSniffer();

    // Uses jQuery unveil library for lazyloading facsimile images
    $("img").unveil(200);

    if (window.ADL.test) {
        window.ADL.toggleHeaders = function () {
            if ($('.navbar-fixed-top').css('opacity') === '1') {
                $('.navbar-fixed-top, .workNavbarFixContainer, .workHeaderFixContainer, .nav-tab-instance-fixContainer').css('opacity', '0.5');
            } else {
                $('.navbar-fixed-top, .workNavbarFixContainer, .workHeaderFixContainer, .nav-tab-instance-fixContainer').css('opacity', '1');
            }
        };
        window.ADL.getHeaderHeight = function () {
            return $('.navbar-fixed-top').height() + $('.workNavbarFixContainer').height() + $('.workHeaderFixContainer').height();
        };
    }

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
    $(window).on('hashchange', ADL.ajustForHeader);

    // also test the scrollTop from loading (if the page starts scrolled)
    // // XXX XXX XXX used to be here: setTimeout(ADL.scrollSniffer, 1000); // start fetching the pagenumber once after load.

    setTimeout(ADL.ajustForHeader, 100); // ajust on document.ready FIXME: This sucks big time, but ADL.ajustForHeader is idempotent so it doesn't screw things up badly
    setTimeout(ADL.ajustForHeader, 500);
    setTimeout(ADL.ajustForHeader, 1500);

    // clicks on nav-tab-instance should correct for scrolling page!
    $('.nav-tab-instance').click(function (e) {
        var pageId = ADL.getCurrentPageId();
        if (pageId && e.target.tagName === 'A') {
            var origHref = $(e.target).attr('href');
            if (origHref.charAt(origHref.length - 1) !== '/') { // append slash if it isn't there already
                origHref = origHref + '/';
            }
            if (origHref.indexOf('#') < 0) {
                $(e.target).attr('href', origHref + '#' + pageId);
            }
            e.preventDefault();
            location.href = $(e.target).attr('href');
            return false;
        }
    });

    //$('#toc .modal-body').click(function () { setTimeout(ADL.ajustForHeader, 0); });

    // modal should be closed as soon as one clicks on a in-page link.
    $('.modal-body').click(function (e) {
        var theATag = $(e.target).closest('a');
        if (theATag.length && theATag.attr('href').charAt(0) === '#') { // If user pressed an a tag or anything inside an a tag, and that tags href starts with a '#' (eg. it's a local link)
            $($(e.target).closest('.modal')).modal('hide');
            setTimeout(ADL.ajustForHeader, 200);
        }
    });

    // Some of our modal dialogs are nested in bars that get fixed. They all should be mounted directly to body.
    $('.modal').appendTo($('body'));

    //setTimeout(ADL.checkAndFixHeaderProblem, 500);
    setTimeout(ADL.ajustForHeader, 500);
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
//        ADL.console.log("cookie: "+ cookie);
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

// FIXME: When is this called? If it is debris, it should be cleaned up /HAFE
function index_work_search(full_id, volume_id, target_selector, text_label_id){
    volume_id = encodeURIComponent(volume_id);
    qselector = $('#q.search_q.q.form-control');
    q = encodeURIComponent($(qselector).val());
    if (!q.trim()){
        $(text_label_id).hide();
    }else{
        $.ajax({
            type: 'GET',
            url: '/catalog.json?search_field=leaf&rows=200&sort=position_isi+asc&q='+q+'&workid='+volume_id,
            datatype: 'json',
            success: function(data) {
                $(target_selector).empty();
                docs = data.response.docs;
                highlighting = data.response.highlighting;
                matches_num = data.response.pages.total_count;
                if (matches_num>0) {
                    $(target_selector).append('<div id="results-header"><p>'+matches_num+' match</p></div>');
                    for (var i= 0; i in docs && i<3; i++) {
                        $(target_selector).append('<p><a href="/solr_documents/'+full_id+(ADL.pageType === 'text' ? extractDivId(docs[i].id) : '#' + docs[i].page_id_ssi)+'">'+highlighting[docs[i].id].text_tesim.join("...")+'</a></br>Side: '+docs[i].page_ssi+'</p>');
                    }
                }else{$(text_label_id).hide();}
            }
        });
    }
    return false;
}

