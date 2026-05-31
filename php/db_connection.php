<?php
$connection=new mysqli("localhost","root","","SportHub");
if($connection->connect_error){
    die("Errore di connessione". $connection->connect_error);
}
?>