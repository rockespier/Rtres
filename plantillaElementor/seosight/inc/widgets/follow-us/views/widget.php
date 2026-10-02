<?php if ( ! defined( 'ABSPATH' ) ) {
	die( 'Direct access forbidden.' );
}
/**
 * @var array  $args
 * @var string $title
 * @var array  $socials
 */

$before_widget = $after_widget = $before_title = $after_title = '';

extract( $args );

seosight_render( $before_widget );

if ( $title ) {
	seosight_render( $before_title . esc_html( $title ) . $after_title );
}
if ( ! empty( $socials ) ) {
	$social_networks = seosight_user_social_networks();
	?>
	<div class="w-follow-wrap"  itemscope itemtype="http://schema.org/Organization">
		<?php foreach ( $socials as $network => $data ) { ?>
			<div class="w-follow-item <?php echo esc_attr( $data['network'] ) ?>-bg-color w-follow-social__item" data-network="follow-<?php echo esc_attr( $data['network'] ) ?>">
					<span class="social-icon">
                        <?php include(get_template_directory().'/svg/socials/' . $data['network'] . '.svg'); ?>
					</span>
					<span class="w-follow-title"><?php echo esc_html( $social_networks[ $data['network'] ]['label'] ) ?>
						<span class="w-follow-add"><i class="seoicon-cross plus"></i><i class="seoicon-check check"></i></span>
					</span>
				<a href="<?php echo esc_url( $data['link'] ); ?>" class="full-block" rel="nofollow" itemprop="sameAs"></a>
			</div>
		<?php } ?>
	</div>
    <script>
        const socials = document.querySelectorAll('.w-follow-social__item');
        document.addEventListener('DOMContentLoaded', function () {
            // Function to get a session storage value
            function getLocalStorage(key) {
                return localStorage.getItem(key);
            }

            // Function to set a session storage value
            function setLocalStorage(key, value) {
                localStorage.setItem(key, value);
            }

            socials.forEach(social => {
                const network = social.getAttribute('data-network');
                if (getLocalStorage(network) === 'true') {
                    social.querySelector('.w-follow-add').classList.add('active');
                }
            });

            socials.forEach(social => {
                social.addEventListener('click', function () {
                    this.querySelector('.w-follow-add').classList.add('active');
                    setLocalStorage(this.getAttribute('data-network'), 'true');
                });
            });
        });
    </script>
<?php } ?>
       <?php
seosight_render( $after_widget );
