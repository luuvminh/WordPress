<?php get_header();?>
<header class="archive-header" style="margin-bottom:32px"><h1 class="entry-title post-title"><?php the_archive_title();?></h1><?php the_archive_description('<div class="entry-content post-body" style="margin-top:8px">','</div>');?></header>
<?php if(have_posts()):while(have_posts()):the_post();?>
<article id="post-<?php the_ID();?>" <?php post_class('post');?>>
  <h2 class="entry-title post-title"><a href="<?php the_permalink();?>"><?php the_title();?></a></h2>
  <div class="entry-content post-body"><?php the_excerpt();?></div>
  <div class="post-meta entry-meta"><span class="post-date entry-date"><?php echo get_the_date('F j, Y');?></span><?php maxlau_seth_share_links();?></div>
</article>
<?php endwhile;?><div class="pagination"><?php the_posts_pagination();?></div>
<?php else:?><article class="post"><h2 class="entry-title post-title">Nothing found</h2></article><?php endif;get_footer();?>
