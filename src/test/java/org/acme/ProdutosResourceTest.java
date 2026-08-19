package org.acme;

import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;

@QuarkusTest
class ProdutosResourceTest {

    @Test
    void testListProdutos() {
        given()
                .when().get("/produtos")
                .then()
                .statusCode(200);
    }

}