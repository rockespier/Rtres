/**
 * @file A WordPress-like hook system for JavaScript.
 *
 * This file demonstrates a simple hook system for JavaScript based on the hook
 * system in WordPress. The purpose of this is to make your code extensible and
 * allowing other developers to hook into your code with their own callbacks.
 *
 * There are other ways to do this, but this will feel right at home for
 * WordPress developers.
 *
 * @author Rheinard Korf
 * @license GPL2 (https://www.gnu.org/licenses/gpl-2.0.html)
 *
 */

/**
 * Hooks object
 *
 * This object needs to be declared early so that it can be used in code.
 * Preferably at a global scope.
 */
var Hooks = Hooks || {}; // Extend Hooks if exists or create new Hooks object.

Hooks.actions = Hooks.actions || {}; // Registered actions
Hooks.filters = Hooks.filters || {}; // Registered filters

/**
 * Add a new Action callback to Hooks.actions
 *
 * @param tag The tag specified by do_action()
 * @param callback The callback function to call when do_action() is called
 * @param priority The order in which to call the callbacks. Default: 10 (like WordPress)
 */
Hooks.add_action = function( tag, callback, priority ) {

    if( typeof priority === "undefined" ) {
        priority = 10;
    }

    // If the tag doesn't exist, create it.
    Hooks.actions[ tag ] = Hooks.actions[ tag ] || [];
    Hooks.actions[ tag ].push( { priority: priority, callback: callback } );

}

/**
 * Add a new Filter callback to Hooks.filters
 *
 * @param tag The tag specified by apply_filters()
 * @param callback The callback function to call when apply_filters() is called
 * @param priority Priority of filter to apply. Default: 10 (like WordPress)
 */
Hooks.add_filter = function( tag, callback, priority ) {

    if( typeof priority === "undefined" ) {
        priority = 10;
    }

    // If the tag doesn't exist, create it.
    Hooks.filters[ tag ] = Hooks.filters[ tag ] || [];
    Hooks.filters[ tag ].push( { priority: priority, callback: callback } );

}

/**
 * Remove an Anction callback from Hooks.actions
 *
 * Must be the exact same callback signature.
 * Warning: Anonymous functions can not be removed.

 * @param tag The tag specified by do_action()
 * @param callback The callback function to remove
 */
Hooks.remove_action = function( tag, callback ) {

    Hooks.actions[ tag ] = Hooks.actions[ tag ] || [];

    Hooks.actions[ tag ].forEach( function( filter, i ) {
        if( filter.callback === callback ) {
            Hooks.actions[ tag ].splice(i, 1);
        }
    } );
}

/**
 * Remove a Filter callback from Hooks.filters
 *
 * Must be the exact same callback signature.
 * Warning: Anonymous functions can not be removed.

 * @param tag The tag specified by apply_filters()
 * @param callback The callback function to remove
 */
Hooks.remove_filter = function( tag, callback ) {

    Hooks.filters[ tag ] = Hooks.filters[ tag ] || [];

    Hooks.filters[ tag ].forEach( function( filter, i ) {
        if( filter.callback === callback ) {
            Hooks.filters[ tag ].splice(i, 1);
        }
    } );
}

/* -----------------------
     * Filter Ajax Portfolio Params
     * --------------------- */
filterAjaxPortfolioParams = function () {
    Hooks.add_filter('ajax_portfolio_replaced_posts', function ($posts, options) {
        var $first = $posts.eq(0);
        var $sec = $posts.eq(1);
        $first.children('.crumina-case-item').addClass('big');
        $sec.children('.crumina-case-item').addClass('big');

        $first.removeClassWild('col-lg-*').removeClassWild('col-md-*').addClass('col-lg-6 col-md-6');
        $sec.removeClassWild('col-lg-*').removeClassWild('col-md-*').addClass('col-lg-6 col-md-6');

        return $posts;
    });

    Hooks.add_filter('ajax_portfolio_scroll_to', function (top, options) {
        return top - 150;
    });
};

filterAjaxPortfolioParams();

/**
 * Calls actions that are stored in Hooks.actions for a specific tag or nothing
 * if there are no actions to call.
 *
 * @param tag A registered tag in Hook.actions
 * @options Optional JavaScript object to pass to the callbacks
 */
Hooks.do_action = function( tag, options ) {

    var actions = [];

    if( typeof Hooks.actions[ tag ] !== "undefined" && Hooks.actions[ tag ].length > 0 ) {

        Hooks.actions[ tag ].forEach( function( hook ) {

            actions[ hook.priority ] = actions[ hook.priority ] || [];
            actions[ hook.priority ].push( hook.callback );

        } );

        actions.forEach( function( hooks ) {

            hooks.forEach( function( callback ) {
                callback( options );
            } );

        } );
    }

}

/**
 * Calls filters that are stored in Hooks.filters for a specific tag or return
 * original value if no filters exist.
 *
 * @param tag A registered tag in Hook.filters
 * @options Optional JavaScript object to pass to the callbacks
 */
Hooks.apply_filters = function( tag, value, options ) {

    var filters = [];

    if( typeof Hooks.filters[ tag ] !== "undefined" && Hooks.filters[ tag ].length > 0 ) {

        Hooks.filters[ tag ].forEach( function( hook ) {

            filters[ hook.priority ] = filters[ hook.priority ] || [];
            filters[ hook.priority ].push( hook.callback );
        } );

        filters.forEach( function( hooks ) {

            hooks.forEach( function( callback ) {
                value = callback( value, options );
            } );

        } );
    }

    return value;
};


( function ( $ ) {
    $.fn.removeClassWild = function ( mask ) {
        return this.removeClass( function ( index, cls ) {
            var re = mask.replace( /\*/g, '\\S+' );
            return ( cls.match( new RegExp( '\\b' + re + '', 'g' ) ) || [ ] ).join( ' ' );
        } );
    };
} )( jQuery );



( function ( $ ) {

    $( document ).ready( function () {

        var $button = $( '#load-more-button' );

        var page_num = parseInt( pagination_data.startPage ) + 1;
        var max_pages = parseInt( pagination_data.maxPages );
        var next_link = $button.data( 'load-link' );

        var loaded_text = pagination_data.loadedText;

        var containerID = pagination_data.container;

        var $container = $( '#' + containerID );
        var container_has_isotope = false;

        if ( page_num > max_pages ) {
            $button.addClass( 'last-page' ).children( '.load-more-text' ).text( loaded_text );
        }

        $button.on( 'click', function () {

            if ( page_num <= max_pages && !$( this ).hasClass( 'loading' ) && !$( this ).hasClass( 'last-page' ) ) {

                $.ajax( {
                    type: 'GET',
                    url: next_link,
                    beforeSend: function () {
                        $button.addClass( 'loading' );
                        page_num++;
                    },
                    complete: function ( XMLHttpRequest ) {
                        if ( XMLHttpRequest.status == 200 && XMLHttpRequest.responseText != '' ) {
                            next_link = next_link.replace( /\/page\/[0-9]?/, '/page/' + page_num );

                            if ( page_num > max_pages ) {
                                $button.addClass( 'last-page' ).children( '.load-more-text' ).text( loaded_text );
                            }
                            //history.pushState('', "/page/" + page_num, next_link);
                            $button.data( 'load-link', next_link );
                            $button.removeClass( 'loading' );

                            if ( $( XMLHttpRequest.responseText ).find( '#' + containerID ).length > 0 ) {
                                container_has_isotope = $container.data( 'isotope' );
                                $( XMLHttpRequest.responseText ).find( '#' + containerID ).children().each( function () {
                                    var elem = $( this );
                                    if ( !container_has_isotope ) {
                                        elem.css( 'opacity', 0 );
                                        $container.append( elem );
                                        elem.addClass( 'animate' );
                                        CRUMINA.Swiper.init(elem.find( '.swiper-container' ));
                                    } else {
                                        $container.isotope( 'insert', elem );
                                        $container.imagesLoaded( function () {
                                            $container.isotope( 'layout' );
                                            CRUMINA.Swiper.init(elem.find( '.swiper-container' ));
                                            var $sorting_buttons = $container.siblings( '.sorting-menu' ).find( 'li' );
                                            $sorting_buttons.each( function () {
                                                var selector = $( this ).data( 'filter' );
                                                var count = $container.find( selector ).length;
                                                if ( count > 0 ) {
                                                    $( this ).css( 'display', 'inline-block' );
                                                }
                                            } );

                                        } );
                                    }
                                } );
                            }
                        }
                    }
                } );
            }
            return false;
        } );
    } );
}( jQuery ) );