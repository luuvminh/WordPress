<?php
function maxlau_seth_setup() {
    add_theme_support('title-tag');
    add_theme_support('post-thumbnails');
    add_theme_support('html5', array('search-form','comment-form','comment-list','gallery','caption'));
    add_theme_support('automatic-feed-links');
    add_theme_support('custom-logo', array('height'=>72,'width'=>72,'flex-height'=>true,'flex-width'=>true));
    register_nav_menus(array('navigate'=>'Navigate Menu','connect'=>'Connect Menu'));
}
add_action('after_setup_theme', 'maxlau_seth_setup');

function maxlau_seth_scripts() {
    wp_enqueue_style('maxlau-seth-fonts','https://fonts.googleapis.com/css2?family=Bebas+Neue&family=PT+Serif:ital,wght@0,400;0,700;1,400&family=Source+Sans+Pro:wght@400;600;700;900&display=swap',array(),null);
    wp_enqueue_style('maxlau-seth-style', get_stylesheet_uri(), array('maxlau-seth-fonts'), '1.0.0');
}
add_action('wp_enqueue_scripts', 'maxlau_seth_scripts');

function maxlau_seth_widgets_init() {
    register_sidebar(array('name'=>'Sidebar','id'=>'sidebar-1','before_widget'=>'<div id="%1$s" class="widget %2$s sidebar-section">','after_widget'=>'</div>','before_title'=>'<h3 class="widget-title">','after_title'=>'</h3>'));
}
add_action('widgets_init', 'maxlau_seth_widgets_init');

function maxlau_seth_search_form($form) {
    return '<form role="search" method="get" class="search-form" action="'.esc_url(home_url('/')).'"><input type="search" class="search-field" value="'.get_search_query().'" name="s" /><button type="submit" class="search-submit">&#128269;</button></form>';
}
add_filter('get_search_form', 'maxlau_seth_search_form');

function maxlau_seth_excerpt_length($l) { return 40; }
add_filter('excerpt_length', 'maxlau_seth_excerpt_length');
function maxlau_seth_excerpt_more($m) { return '&hellip;'; }
add_filter('excerpt_more', 'maxlau_seth_excerpt_more');

function maxlau_seth_share_links() {
    $u=urlencode(get_permalink()); $t=urlencode(get_the_title());
    echo '<div class="share-icons">';
    echo '<a href="https://www.facebook.com/sharer/sharer.php?u='.$u.'" target="_blank" rel="noopener">&#xf09a;</a>';
    echo '<a href="https://twitter.com/intent/tweet?url='.$u.'&text='.$t.'" target="_blank" rel="noopener">&#xf099;</a>';
    echo '<a href="https://www.linkedin.com/shareArticle?mini=true&url='.$u.'" target="_blank" rel="noopener">&#xf0e1;</a>';
    echo '<a href="javascript:void(0);" onclick="navigator.clipboard.writeText(\''.esc_js(get_permalink()).'\')" title="Copy link">&#x1f517;</a>';
    echo '</div>';
}
