import 'dart:ffi';

class JobOrderData {
  final int updateId;
  final double sumOfSubtotal;
  final int discount;
  final double subTotalWithDiscount;
  final double vat;
  final double grossPrice;
  final int discountPercent;
  final List<PoItem> poItems;

  JobOrderData({
    required this.updateId,
    required this.sumOfSubtotal,
    required this.discount,
    required this.subTotalWithDiscount,
    required this.vat,
    required this.grossPrice,
    required this.discountPercent,
    required this.poItems,
  });

  Map<String, dynamic> toJson() {
    return {
      "update_id": updateId,
      "sum_of_subtotal": sumOfSubtotal,
      "discount": discount,
      "sub_total_with_discount": subTotalWithDiscount,
      "vat": vat,
      "gross_price": grossPrice,
      "discount_percent": discountPercent,
      "po_items": poItems.map((item) => item.toJson()).toList(),
    };
  }
}

class PoItem {
  final int id;
  final int productId;
  final int unitPrice;
  final int qty;
  final int requestQty;
  final int subTotalPrice;
  final double subTotalVatPrice;
  final int itemDiscountPercent;
  final int itemDiscountAmount;
  final double productVat;

  PoItem({
  required this.id,
  required this.productId,
  required this.unitPrice,
  required this.qty,
  required this.requestQty,
  required this.subTotalPrice,
  required this.subTotalVatPrice,
  required this.itemDiscountPercent,
  required this.itemDiscountAmount,
  required this.productVat,
});

Map<String, dynamic> toJson() {
  return {
    "id": id,
    "product_id": productId,
    "unit_price": unitPrice,
    "qty": qty,
    "request_qty": requestQty,
    "sub_total_price": subTotalPrice,
    "sub_total_vat_price": subTotalVatPrice,
    "item_discount_percent": itemDiscountPercent,
    "item_discount_amount": itemDiscountAmount,
    "product_vat": productVat,
  };
}
}