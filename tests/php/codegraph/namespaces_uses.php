<?php

class UseNamespace extends N\AInN 
{
}

use N\AInN;
function test_namespace_use() {
  $o = new AInN();
}

use N\AInN as Bar;
function test_namespace_alias() {
  $o = new Bar();
}