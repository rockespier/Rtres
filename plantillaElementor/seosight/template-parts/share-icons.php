<span class="label"><?php esc_html_e( 'Share', 'seosight' ); ?>:</span>
<button  class="social__item social-facebook sharer" data-sharer="facebook" data-url="<?php the_permalink(); ?>" data-image="<?php the_post_thumbnail_url('medium'); ?>">
    <img loading="lazy" width="24" height="24" src="<?php echo esc_url( get_template_directory_uri() . '/svg/socials/facebook.svg' ); ?>" alt="facebook">
</button>
<button class="social__item social-twitter sharer" data-sharer="twitter" data-title="<?php echo esc_attr(get_the_title()); ?>" data-url="<?php the_permalink();?>" >
    <img loading="lazy" width="24" height="24" src="<?php echo esc_url( get_template_directory_uri() . '/svg/socials/twitter.svg' ); ?>" alt="twitter">
</button>
<button class="social__item social-linkedin sharer" data-sharer="linkedin" data-url="<?php the_permalink(); ?>">
    <img loading="lazy" width="24" height="24" src="<?php echo esc_url( get_template_directory_uri() . '/svg/socials/linkedin.svg' ); ?>" alt="linkedin">
</button>
<button class="social__item social-pinterest sharer" data-sharer="pinterest" data-url="<?php the_permalink(); ?>" data-image="<?php the_post_thumbnail_url('large'); ?>" >
    <img loading="lazy" width="24" height="24" src="<?php echo esc_url( get_template_directory_uri() . '/svg/socials/pinterest.svg' ); ?>" alt="pinterest">
</button>
<button class="social__item social-whatsapp sharer" data-sharer="whatsapp" data-url="<?php the_permalink(); ?>" data-image="<?php the_post_thumbnail_url('large'); ?>" >
    <img loading="lazy" width="24" height="24" src="<?php echo esc_url( get_template_directory_uri() . '/svg/socials/whatsapp.svg' ); ?>" alt="whatsapp">
</button>