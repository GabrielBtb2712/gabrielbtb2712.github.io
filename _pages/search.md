---
layout: page
title: Buscador
permalink: /search/
---

<style>
  /* Estilos generales */
  body {
    font-family: 'Arial', sans-serif;
    background-color: #1e1e1e;
    color: #ffffff;
    margin: 0;
    padding: 20px;
  }

  .search-container {
    max-width: 800px;
    margin: 0 auto;
    padding: 20px;
  }

  #search-form {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 10px;
    margin-bottom: 20px;
  }

  #search-box {
    padding: 12px;
    font-size: 18px;
    border: 2px solid #444;
    border-radius: 5px;
    width: 100%;
    max-width: 400px;
    background-color: #2d2d2d;
    color: #ffffff;
    transition: all 0.3s ease;
  }

  #search-box:focus {
    border-color: rgb(59, 180, 144);
    box-shadow: 0 0 10px rgb(59, 180, 144);
    transform: scale(1.05);
  }

  #search-form input[type="submit"] {
    padding: 12px 20px;
    font-size: 18px;
    background-color: rgb(59, 180, 144);
    color: #ffffff;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    transition: background-color 0.3s ease;
    width: 100%;
    max-width: 180px;
  }

  #search-form input[type="submit"]:hover {
    background-color: rgb(45, 140, 110);
  }

  #search-results {
    width: 100%;
  }

  .result-item {
    background-color: #2d2d2d;
    padding: 20px;
    border-radius: 5px;
    margin-bottom: 15px;
    transition: transform 0.3s ease;
  }

  .result-item:hover {
    transform: translateY(-5px);
  }

  .result-item h3 {
    margin: 0;
    color: rgb(59, 180, 144);
    font-size: 20px;
  }

  .result-item p {
    margin: 10px 0 0;
    color: #cccccc;
    font-size: 16px;
  }

  .loading {
    display: none;
    text-align: center;
    font-size: 20px;
    color: rgb(59, 180, 144);
    margin-top: 20px;
  }

  /* Estilos responsivos */
  @media (max-width: 600px) {
    #search-form {
      flex-direction: column;
      align-items: stretch;
    }

    #search-box {
      font-size: 16px;
      padding: 10px;
    }

    #search-form input[type="submit"] {
      font-size: 16px;
      padding: 10px;
      max-width: 100%;
    }

    .result-item {
      padding: 15px;
    }
  }
</style>

<div class="search-container">
  <form id="search-form">
    <input type="text" id="search-box" placeholder="Escribe una palabra clave...">
    <input type="submit" value="Buscar">
  </form>

  <div class="loading" id="loading">Buscando...</div>
  <div id="search-results"></div>
</div>

<script src="https://unpkg.com/lunr/lunr.js"></script>
<script>
  let idx;
  let searchData = {};

  fetch('/search-index.json')
    .then(response => response.json())
    .then(data => {
      idx = lunr(function () {
        this.ref('id');
        this.field('title', { boost: 10 });
        this.field('content');
        this.field('tags');
        this.field('categories');

        data.forEach((doc, id) => {
          doc.id = id;
          this.add(doc);
          searchData[id] = doc;
        });
      });
      console.log('Índice cargado correctamente:', idx);
    })
    .catch(error => {
      console.error('Error cargando el índice:', error);
    });

  document.getElementById('search-form').addEventListener('submit', function (event) {
    event.preventDefault();
    const query = document.getElementById('search-box').value.trim();
    const resultsContainer = document.getElementById('search-results');
    const loading = document.getElementById('loading');

    if (!query) {
      resultsContainer.innerHTML = '<p>Por favor, ingresa una palabra clave.</p>';
      return;
    }

    loading.style.display = 'block';
    resultsContainer.innerHTML = '';

    setTimeout(() => {
      const results = idx.search(query);
      loading.style.display = 'none';

      if (results.length > 0) {
        resultsContainer.innerHTML = results.map(result => {
          const doc = searchData[result.ref];
          return `
            <div class="result-item">
              <h3><a href="${doc.url}">${doc.title}</a></h3>
              <p>${doc.content.substring(0, 150)}...</p>
            </div>`;
        }).join('');
      } else {
        resultsContainer.innerHTML = '<p>No se encontraron resultados.</p>';
      }
    }, 500);
  });
</script>