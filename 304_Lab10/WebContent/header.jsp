   <style>
.header {
            face: "cursive"
            color: #3399FF;
            padding: 10px 20px;
            display: flex;
            justify-content: center;
            align-items: center;
}
.bar {
    padding: 10px 0;
    display: flex;
    justify-content: space-evenly;
}
</style>
<header>
    <H1 align="center"><a href="index.jsp">Evan and Ian's Shop</a></font></H1>
    <nav class="bar">
            <a href="listprod.jsp">Products</a>
            <a href="showcart.jsp">Cart</a>
            <a href="listorder.jsp">Orders</a>
            <a href="customer.jsp">Customers</a>
            <a href="admin.jsp">Admin</a>
            <a href="logout.jsp">Logout</a>
            <%
            String userName = (String) session.getAttribute("authenticatedUser");
            if (userName != null)
                out.println("<span><h3 align=\"center\">Signed in as: "+userName+"</h3></span>");
            else
                out.println("<a href=\"login.jsp\">Login</a>");
            %> 

    </nav>
</header>
<hr>
