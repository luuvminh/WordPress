<?php get_header(); ?>
<?php if(have_posts()):while(have_posts()):the_post();?>
<article id="post-<?php the_ID();?>" <?php post_class('post');?>>
  <h2 class="entry-title post-title"><a href="<?php the_permalink();?>"><?php the_title();?></a></h2>
  <div class="entry-content post-body"><?php the_content();?></div>
  <div class="post-meta entry-meta"><span class="post-date entry-date"><?php echo get_the_date('F j, Y');?></span><?php maxlau_seth_share_links();?></div>
</article>
<?php endwhile;?>
<div class="pagination"><?php the_posts_pagination(array('prev_text'=>'&laquo; Newer','next_text'=>'Older &raquo;'));?></div>
<?php else:?>
<article class="post"><h2 class="entry-title post-title">Nothing here yet</h2><div class="entry-content post-body"><p>No posts found.</p></div></article>
<?php endif; get_footer();?>
