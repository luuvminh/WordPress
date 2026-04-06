<?php get_header();?>
<header style="margin-bottom:32px"><h1 class="entry-title post-title">Search results for: <?php the_search_query();?></h1></header>
<?php if(have_posts()):while(have_posts()):the_post();?>
<article id="post-<?php the_ID();?>" <?php post_class('post');?>>
  <h2 class="entry-title post-title"><a href="<?php the_permalink();?>"><?php the_title();?></a></h2>
  <div class="entry-content post-body"><?php the_excerpt();?></div>
  <div class="post-meta entry-meta"><span class="post-date entry-date"><?php echo get_the_date('F j, Y');?></span></div>
</article>
<?php endwhile;?><div class="pagination"><?php the_posts_pagination();?></div>
<?php else:?><article class="post"><h2 class="entry-title post-title">No results</h2><div class="entry-content post-body"><p>Try different keywords.</p><?php get_search_form();?></div></article><?php endif;get_footer();?>
