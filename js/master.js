// change navbar style on scroll

window.addEventListener('scroll', () =>{
    document.querySelector('nav').classList.toggle('window-scroll', window.scrollY > 0)
})

// show/hide nav menu

const menu = document.querySelector('.nav-menu');
const openMenuButton = document.querySelector('#open-menu-button');
const closeMenuButton = document.querySelector('#close-menu-button');

openMenuButton.addEventListener('click', () => {
    menu.style.display = "flex";
    closeMenuButton.style.display = "inline-block";
    openMenuButton.style.display = "none";
}) 

const closeNav = () => {
    menu.style.display = "none";
    closeMenuButton.style.display = "none";
    openMenuButton.style.display = "inline-block";
}

closeMenuButton.addEventListener('click', closeNav)

// animation on scroll

function reveal() {
    var reveals = document.querySelectorAll(".reveal");
    for (var i = 0; i < reveals.length; i++) {
        var windowHeight = window.innerHeight;
        var elementTop = reveals[i].getBoundingClientRect().top;
        var elementVisible = 150;
        if (elementTop < windowHeight - elementVisible) {
            reveals[i].classList.add("active");
        } else {
            reveals[i].classList.remove("active");
        }
    }
}

window.addEventListener("scroll", reveal);

// To check the scroll position on page load
reveal();