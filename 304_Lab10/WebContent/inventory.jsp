<%@ page import="java.sql.*,java.net.URLEncoder" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="javax.xml.transform.Result" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%@ include file="jdbc.jsp" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Evan and Ian's Grocery</title>
    <style>
body {
    font-family: 'Arial', sans-serif;
    background-color: #f8f9fa; /* Lighter background color for better contrast */
    margin: 0;
    padding: 20px;
    color: #333; /* Dark text for readability */
}

/* Header styling */
h1 {
    color: #343a40; /* Darker text for better contrast */
    text-align: center; /* Center-align header */
    font-size: 2.5em;
    margin-bottom: 20px;
}

/* Form styling */
form {
    margin-bottom: 20px;
    text-align: center; /* Center-align the form */
}

/* Input styling for text fields */
input[type="text"] {
    padding: 12px 15px; /* Increased padding for better usability */
    width: 100%;
    max-width: 400px; /* Limit max width for larger screens */
    border-radius: 8px; /* Rounded corners */
    border: 1px solid #ccc;
    font-size: 16px;
    margin: 15px; /* Added space below input fields */
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1); /* Subtle shadow for a clean look */
}

/* Submit and reset button styling */
input[type="submit"], input[type="reset"] {
    padding: 12px 30px;
    background-color: #28a745; /* Green background for submit button */
    color: white;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    font-size: 16px;
    transition: background-color 0.3s ease; /* Smooth transition effect */
    margin: 7px;
}

input[type="reset"] {
    background-color: #dc3545; /* Red background for reset button */
}

input[type="submit"]:hover {
    background-color: #218838; /* Darker green when hovered */
}

input[type="reset"]:hover {
    background-color: #c82333; /* Darker red when hovered */
}

/* Link styling */
a {
    color: #007bff; /* Blue color for links */
    text-decoration: none;
    font-weight: 600; /* Slightly bolder font for links */
}

a:hover {
    text-decoration: underline;
}

/* Product list grid styling */
.product-list {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); /* Responsive grid */
    gap: 20px; /* Space between product items */
    margin-top: 20px;
}

/* Individual product item styling */
.product-item {
    background-color: #ffffff; /* White background for product items */
    padding: 20px;
    border-radius: 8px;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); /* Subtle shadow */
    transition: transform 0.2s ease, box-shadow 0.2s ease; /* Smooth transition for hover effects */
}

/* Hover effect for product items */
.product-item:hover {
    transform: translateY(-5px); /* Lift effect when hovering */
    box-shadow: 0 6px 12px rgba(0, 0, 0, 0.15); /* Deeper shadow on hover */
}

/* Add to cart button styling */
.addcart {
    display: inline-flex;
    padding: 10px 20px;
    background-color: #007bff; /* Blue button */
    color: white;
    border-radius: 5px;
    font-size: 16px;
    cursor: pointer;
    align-items: center;
    justify-content: center;
    transition: background-color 0.3s ease;
    margin: 5px; 
}

.addcart:hover {
    background-color: #0056b3; /* Darker blue on hover */
}

/* Add to cart button on mobile */
.addcart:active {
    background-color: #004085; /* Even darker blue when clicked */
}
.warehouse-header {
    margin-top: 20px;
    margin-bottom: 20px;
}

    </style>
</head>
<body>

<div class="product-list">
    <%
        try {
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (java.lang.ClassNotFoundException e) {
            out.println("ClassNotFoundException: " + e);
        }

        try (Connection con = DriverManager.getConnection(url, uid, pw)) {
            Statement stmt = con.createStatement(); 
            stmt.execute("USE orders");
            String query = "SELECT warehouseId, productName, quantity, price, p.productId FROM productinventory pi JOIN product p ON pi.productId=p.productId ORDER BY warehouseId ASC";
            PreparedStatement preparedStatement = con.prepareStatement(query);
            ResultSet resultSet = preparedStatement.executeQuery();

            int wid = -1;
            while (resultSet.next()) {
                int temp = resultSet.getInt("warehouseId");
                if(temp!=wid){
                    wid = temp;
                    out.println("<h2 class='warehouse-header'>Warehouse "+wid+" inventory:</h2>");
                }
                String pname = resultSet.getString("productName");
                int qty = resultSet.getInt("quantity");
                double pp = resultSet.getDouble("price");
                int pid = resultSet.getInt(5);

    %>
    <div class="product-item">
        <strong>
            <a href="<%= "product.jsp?id="+pid %>"> <%= pname %></a>
        </strong><br>
        Price: $<%= pp %> <br>
        Quantity: <%= qty %>
    </div>
    <%
            }
        } catch (SQLException e) {
            out.println(e);
        }
    %>
</div>

</body>
</html>
