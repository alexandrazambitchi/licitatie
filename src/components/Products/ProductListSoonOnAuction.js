import React, { Component } from "react";
import { Link } from "react-router-dom";
import ProductSoon from "./ProductSoon";
import "../App.css";

class ProductListSoonOnAuction extends Component {
  render() {
    return (
      <div className="p-2 flex-grow-1 bd-highlight">
        <p>&nbsp;</p>
        {/* <h2>Product List</h2> */}
        <section className="section">
          {this.props.productsOnAuction < 1 ? (
            <h2 className="section-title">No results</h2>
          ) : (
            <section className="section">
              <h2 className="section-title">Products</h2>
              <h3 className="section-title">Soon on auction</h3>
              <div className="product-center">
                {this.props.products.map((product, key) => {
                  return <ProductSoon key={key} {...product} />;
                })}
              </div>
            </section>
          )}
        </section>
      </div>
    );
  }
}

export default ProductListSoonOnAuction;
