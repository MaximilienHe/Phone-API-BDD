let articles_link_array = [];

async function fetchPagesSequentially(baseUrl, startPage = 1) {
    let page_number = startPage;
    let is_there_content = true;

    while (is_there_content) {
        try {
            const response = await fetch(baseUrl + page_number);
            const data = await response.json();

            if (data.code != "rest_post_invalid_page_number") {
                for (let index = 0; index < data.length; index++) {
                    const element = data[index];
                    articles_link_array.push(element.link);
                }
                page_number++;
            } else {
                is_there_content = false;
            }
        } catch (error) {
            console.error("Erreur lors de la récupération des pages :", error);
            is_there_content = false;
        }
    }
}

async function fetchAllArticles() {
    const postsResponse = await fetch("https://startupworld.tech/wp-json/wp/v2/posts");
    const postsData = await postsResponse.json();
    for (let index = 0; index < postsData.length; index++) {
        const element = postsData[index];
        articles_link_array.push(element.link);
    }

    await fetchPagesSequentially("https://startupworld.tech/wp-json/wp/v2/pages?page=", 2);

    console.log(articles_link_array);
}

fetchAllArticles();
