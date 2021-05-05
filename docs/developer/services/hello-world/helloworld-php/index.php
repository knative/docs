<?php
$target = getenv('TARGET', true) ?: 'World';
echo sprintf("Hello %s!\n", $target);
?>
