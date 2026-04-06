<?php get_header(); while(have_posts()):the_post();?>
<article id="post-<?php the_ID();?>" <?php post_class('post');?>>
  <h1 class="entry-title post-title"><?php the_title();?></h1>
  <div class="entry-content post-body"><?php the_content();?></div>
  <div class="post-meta entry-meta"><span class="post-date entry-date"><?php echo get_the_date('F j, Y');?></span><?php maxlau_seth_share_links();?></div>
</article>
<nav class="post-navigation" style="margin-top:24px;font-family:'Source Sans Pro',sans-serif;font-size:14px;font-weight:700;display:flex;justify-content:space-between;"><div><?php previous_post_link('%link','&laquo; %title');?></div><div><?php next_post_link('%link','%title &raquo;');?></div></nav>
<?php if(comments_open()||get_comments_number()){comments_template();}endwhile;get_footer();?>
