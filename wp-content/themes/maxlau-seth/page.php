<?php get_header(); while(have_posts()):the_post();?>
<article id="post-<?php the_ID();?>" <?php post_class('page');?>>
  <h1 class="entry-title post-title"><?php the_title();?></h1>
  <div class="entry-content post-body"><?php the_content();?></div>
</article>
<?php if(comments_open()||get_comments_number()){comments_template();}endwhile;get_footer();?>
