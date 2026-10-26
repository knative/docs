<?php
header('Content-Type: text/plain; charset=UTF-8');
$target = getenv('TARGET', true) ?: 'World';
echo sprintf("Hello %s!\n", $target);
?>
