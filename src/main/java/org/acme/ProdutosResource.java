package org.acme;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;

import java.util.List;

@Path("/produtos")
public class ProdutosResource {

    @GET
    public List<Produto> list() {
        return List.of(
                new Produto(1L, "Notebook", 4500.00),
                new Produto(2L, "Mouse Sem Fio", 120.50),
                new Produto(3L, "Teclado Mecânico", 350.00)
        );
    }
}
