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