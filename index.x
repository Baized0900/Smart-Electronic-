<!DOCTYPE html>
<html lang="bn">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Smart Electronic</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
  <style>
    body { font-family: 'Noto Sans Bengali', sans-serif; background: #f8f9fa; }
    .product-card img { height: 180px; object-fit: cover; }
    footer { font-size: 0.9rem; }
  </style>
</head>
<body>
  <!-- Navbar -->
  <nav class="navbar navbar-expand-lg navbar-dark bg-dark sticky-top shadow">
    <div class="container">
      <a class="navbar-brand" href="#">Smart Electronic</a>
      <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navMenu">
        <span class="navbar-toggler-icon"></span>
      </button>
      <div class="collapse navbar-collapse" id="navMenu">
        <ul class="navbar-nav ms-auto align-items-center">
          <li class="nav-item"><button id="loginBtn" class="btn btn-outline-light me-2">লগইন</button></li>
          <li class="nav-item position-relative">
            <button id="cartBtn" class="btn btn-outline-success">
              কার্ট 🛒 <span id="cartCount" class="badge bg-danger rounded-pill">0</span>
            </button>
          </li>
          <li class="nav-item d-none" id="logoutItem"><button id="logoutBtn" class="btn btn-outline-warning">লগআউট</button></li>
        </ul>
      </div>
    </div>
  </nav>

  <!-- Products Grid -->
  <main class="container my-4">
    <h2 class="mb-4 text-center">নতুন প্রোডাক্ট সমূহ</h2>
    <div id="productGrid" class="row g-4"></div>
  </main>

  <!-- Cart Modal -->
  <div class="modal fade" id="cartModal" tabindex="-1" aria-labelledby="cartModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-scrollable">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title" id="cartModalLabel">আপনার কার্ট</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <div class="modal-body">
          <ul id="cartItems" class="list-group mb-3"></ul>
          <h5>মোট: <span id="cartTotal">০</span> ৳</h5>
        </div>
        <div class="modal-footer">
          <button id="checkoutBtn" class="btn btn-primary" disabled>চেকআউট</button>
        </div>
      </div>
    </div>
  </div>

  <!-- Checkout Modal -->
  <div class="modal fade" id="checkoutModal" tabindex="-1" aria-labelledby="checkoutModalLabel" aria-hidden="true">
    <div class="modal-dialog">
      <form class="modal-content" id="checkoutForm">
        <div class="modal-header">
          <h5 class="modal-title" id="checkoutModalLabel">অর্ডার তথ্য পূরণ করুন</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <div class="modal-body">
          <div class="mb-3">
            <label for="customerName" class="form-label">নাম</label>
            <input type="text" class="form-control" id="customerName" required />
          </div>
          <div class="mb-3">
            <label for="customerPhone" class="form-label">মোবাইল নম্বর</label>
            <input type="tel" class="form-control" id="customerPhone" required pattern="^\d{11}$" placeholder="01XXXXXXXXX" />
          </div>
          <div class="mb-3">
            <label for="customerAddress" class="form-label">ঠিকানা</label>
            <textarea class="form-control" id="customerAddress" rows="2" required></textarea>
          </div>
          <div class="mb-3">
            <label for="paymentMethod" class="form-label">পেমেন্ট পদ্ধতি</label>
            <select id="paymentMethod" class="form-select" required>
              <option value="COD">Cash on Delivery</option>
              <option value="bKash">bKash</option>
              <option value="Nagad">Nagad</option>
            </select>
          </div>
        </div>
        <div class="modal-footer">
          <button type="submit" class="btn btn-success w-100">অর্ডার কনফার্ম</button>
        </div>
      </form>
    </div>
  </div>

  <!-- Firebase SDKs -->
  <script type="module">
    import { initializeApp } from "https://www.gstatic.com/firebasejs/9.23.0/firebase-app.js";
    import { getAuth, onAuthStateChanged, signInWithPopup, GoogleAuthProvider, signOut } from "https://www.gstatic.com/firebasejs/9.23.0/firebase-auth.js";
    import { getDatabase, ref, set, push, onValue } from "https://www.gstatic.com/firebasejs/9.23.0/firebase-database.js";

    // Firebase Config (Your Config Here)
    const firebaseConfig = {
      apiKey: "AIzaSyAfey0QL6aUGkj9-31EWN9_GPHXJ2ZWbO8",
      authDomain: "smart-electronic-846c3.firebaseapp.com",
      projectId: "smart-electronic-846c3",
      storageBucket: "smart-electronic-846c3.appspot.com",
      messagingSenderId: "207141006872",
      appId: "1:207141006872:web:e2e55098f26e8c2d5e1d6d",
      measurementId: "G-7VHGVJE7K5"
    };

    // Initialize Firebase
    const app = initializeApp(firebaseConfig);
    const auth = getAuth(app);
    const database = getDatabase(app);

    // Elements
    const loginBtn = document.getElementById('loginBtn');
    const logoutBtn = document.getElementById('logoutBtn');
    const logoutItem = document.getElementById('logoutItem');
    const cartBtn = document.getElementById('cartBtn');
    const cartCount = document.getElementById('cartCount');
    const productGrid = document.getElementById('productGrid');
    const cartModal = new bootstrap.Modal(document.getElementById('cartModal'));
    const checkoutModal = new bootstrap.Modal(document.getElementById('checkoutModal'));
    const cartItemsList = document.getElementById('cartItems');
    const cartTotalDisplay = document.getElementById('cartTotal');
    const checkoutBtn = document.getElementById('checkoutBtn');

    // Product List
    const products = [
      { id: 1, name: 'স্মার্টফোন', price: 15990, img: 'https://via.placeholder.com/300x180?text=Smartphone' },
      { id: 2, name: 'চার্জার', price: 599, img: 'https://via.placeholder.com/300x180?text=Charger' },
      { id: 3, name: 'ইয়ারফোন', price: 899, img: 'https://via.placeholder.com/300x180?text=Earphone' },
      { id: 4, name: 'স্মার্টওয়াচ', price: 3490, img: 'https://via.placeholder.com/300x180?text=Smartwatch' },
      { id: 5, name: 'পাওয়ার ব্যাংক', price: 1990, img: 'https://via.placeholder.com/300x180?text=Power+Bank' },
      { id: 6, name: 'LED টিভি', price: 31990, img: 'https://via.placeholder.com/300x180?text=LED+TV' },
      { id: 7, name: 'ল্যাপটপ', price: 48990, img: 'https://via.placeholder.com/300x180?text=Laptop' },
    ];

    // Cart Array
    let cart = [];

    // Load cart from localStorage
    function loadCart() {
      const saved = localStorage.getItem('smartCart');
      if (saved) cart = JSON.parse(saved);
      else cart = [];
    }

    // Save cart to localStorage
    function saveCart() {
      localStorage.setItem('smartCart', JSON.stringify(cart));
    }

    // Update cart UI count and modal list
    function updateCartUI() {
      let total = 0;
      let count = 0;
      cartItemsList.innerHTML = '';
      cart.forEach(item => {
        const product = products.find(p => p.id === item.id);
        const price = product.price * item.qty;
        total += price;
        count += item.qty;
        const li = document.createElement('li');
        li.className = 'list-group-item d-flex justify-content-between align-items-center';
        li.textContent = `${product.name} × ${item.qty} - ${price.toLocaleString('bn-BD')} ৳`;
        cartItemsList.appendChild(li);
      });
      cartCount.textContent = count;
      cartTotalDisplay.textContent = total.toLocaleString('bn-BD');
      checkoutBtn.disabled = count === 0;
    }

    // Add to cart
    function addToCart(id) {
      const found = cart.find(item => item.id === id);
      if (found) found.qty++;
      else cart.push({ id: id, qty: 1 });
      saveCart();
      updateCartUI();
    }

    // Render products
    function renderProducts() {
      productGrid.innerHTML = '';
      products.forEach(p => {
        const col = document.createElement('div');
        col.className = 'col-6 col-md-4 col-lg-3';
        col.innerHTML = `
          <div class="card h-100 shadow-sm product-card">
            <img src="${p.img}" alt="${p.name}" class="card-img-top" />
            <div class="card-body d-flex flex-column">
              <h5 class="card-title">${p.name}</h5>
              <p class="fw-bold mb-2">${p.price.toLocaleString('bn-BD')} ৳</p>
              <button class="btn btn-primary mt-auto" data-id="${p.id}">কার্টে যোগ করুন</button>
            </div>
          </div>`;
        productGrid.appendChild(col);
      });
    }

    // Event listeners
    productGrid.addEventListener('click', e => {
      if (e.target.tagName === 'BUTTON' && e.target.dataset.id) {
        addToCart(parseInt(e.target.dataset.id));
      }
    });

    cartBtn.addEventListener('click', () => {
      updateCartUI();
      cartModal.show();
    });

    checkoutBtn.addEventListener('click', () => {
      cartModal.hide();
      checkoutModal.show();
    });

    document.getElementById('checkoutForm').addEventListener('submit', e => {
      e.preventDefault();
      const name = document.getElementById('customerName').value.trim();
      const phone = document.getElementById('customerPhone').value.trim();
      const address = document.getElementById('customerAddress').value.trim();
      const paymentMethod = document.getElementById('paymentMethod').value;

      if (cart.length === 0) {
        alert('আপনার কার্ট খালি।');
        return;
      }

      // Save order to Firebase Realtime Database
      const ordersRef = ref(database, 'orders');
      const newOrderRef = push(ordersRef);
      set(newOrderRef, {
        name, phone, address, paymentMethod,
        cart,
        timestamp: Date.now(),
        status: 'Pending'
      }).then(() => {
        alert(`ধন্যবাদ ${name}! আপনার অর্ডার সফলভাবে গ্রহণ করা হয়েছে। আমরা শিগগিরই যোগাযোগ করব।`);
        cart = [];
        saveCart();
        updateCartUI();
        checkoutModal.hide();
        document.getElementById('checkoutForm').reset();
      }).catch(error => {
        alert('দুঃখিত, অর্ডার দেওয়া সম্ভব হয়নি। আবার চেষ্টা করুন।');
        console.error(error);
      });
    });

    // Authentication
    const provider = new GoogleAuthProvider();

    loginBtn.addEventListener('click', () => {
      signInWithPopup(auth, provider).catch(console.error);
    });

    logoutBtn.addEventListener('click', () => {
      signOut(auth).catch(console.error);
    });

    // Monitor auth state
    onAuthStateChanged(auth, user => {
      if (user) {
        loginBtn.classList.add('d-none');
        logoutItem.classList.remove('d-none');
        // Show admin features here in future
      } else {
        loginBtn.classList.remove('d-none');
        logoutItem.classList.add('d-none');
      }
    });

    // Init
    loadCart();
    renderProducts();
    updateCartUI();
  </script>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
