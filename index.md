---
layout: default
title: Knowledge Base Index
---

# Knowledge Base Index

Ecco le tue KB disponibili:

<ul>
  {% assign docs = site.kb | sort: "title" %}
  {% for doc in docs %}
    <li>
      <a href="{{ doc.url | relative_url }}" target="_blank">
        {{ doc.title | default: doc.name }}
      </a>
    </li>
  {% endfor %}
</ul>