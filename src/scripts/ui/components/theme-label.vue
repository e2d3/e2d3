<template lang="jade">
table.color-table
  tr
    td(v-for='color in colors', :style="{ 'background-color': color }") &#x200A;
| {{name}}
</template>

<script lang="coffee">
$ = require 'jquery'

module.exports =
  props: ['name', 'colors']
</script>
