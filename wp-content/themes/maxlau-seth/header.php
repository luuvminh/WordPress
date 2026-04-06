<!DOCTYPE html>
<html <?php language_attributes(); ?>>
<head>
<meta charset="<?php bloginfo('charset'); ?>">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<?php wp_head(); ?>
</head>
<body <?php body_class(); ?>>
<?php wp_body_open(); ?>
<div class="top-bar"></div>
<div class="site-wrapper">
  <aside class="sidebar">
    <div class="sidebar-header">
      <div class="avatar"><?php if(has_custom_logo()){the_custom_logo();}else{echo 'ML';}?></div>
      <a href="<?php echo esc_url(home_url('/')); ?>" class="site-title"><?php bloginfo('name'); ?></a>
    </div>
    <div class="sidebar-section"><h3>Search</h3><?php get_search_form(); ?></div>
    <div class="sidebar-section">
      <h3>Subscribe</h3>
      <div class="subscribe-box"><input type="email" placeholder="me@email.com"><button onclick="window.location.href='mailto:<?php echo antispambot(get_option('admin_email'));?>?subject=Subscribe'">Sign Up</button></div>
      <div class="email-terms"><a href="<?php echo esc_url(get_privacy_policy_url()); ?>">Privacy Policy</a></div>
    </div>
    <?php if(has_nav_menu('navigate')):?><div class="sidebar-section"><h3>Navigate</h3><?php wp_nav_menu(array('theme_location'=>'navigate','container'=>false,'depth'=>1));?></div><?php else:?><div class="sidebar-section"><h3>Navigate</h3><ul><li><a href="<?php echo esc_url(home_url('/'));?>">Home</a></li><?php wp_list_pages(array('title_li'=>'','depth'=>1));?></ul></div><?php endif;?>
    <?php if(has_nav_menu('connect')):?><div class="sidebar-section"><h3>Connect</h3><?php wp_nav_menu(array('theme_location'=>'connect','container'=>false,'depth'=>1));?></div><?php endif;?>
    <?php if(is_active_sidebar('sidebar-1')){dynamic_sidebar('sidebar-1');}?>
  </aside>
  <main class="main-content">
