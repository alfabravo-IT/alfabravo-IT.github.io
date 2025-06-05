---
layout: default
title: KB Index
---

# Knowledge Base Index

Ecco le tue KB disponibili:

<ul>
  {% assign pages = site.pages | sort: "title" %}
  {% for page in pages %}
    {% if page.extname == ".md" and page.path != "index.md" %}
      <li>
        <a href="{{ page.url | relative_url }}" target="_blank">
          {{ page.title | default: page.name }}
        </a>
      </li>
    {% endif %}
  {% endfor %}
</ul>