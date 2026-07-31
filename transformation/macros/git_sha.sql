{%- macro git_sha() -%}
  {{- env_var('GIT_SHA', 'local') | trim -}}
{%- endmacro -%}
