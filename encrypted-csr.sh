printf "%b\n" "\nEncrypted certificate privatekey and CSR -generator script\nVER 1.0 \nby Alex Mäkinen\n\n"

echo "Please input Certificate Name"
read certname
while [[ -z $certname ]]; do
  echo Certificate name is oblicatory!
  read certname
done
declare -A subjects
subjects[CN]=$certname

echo "Please input Organization Name"
read organization
subjects[O]=$organization

echo "Please input Division Name"
read division
subjects[OU]=$division

echo "Please input Locality"
read locality
subjects[L]=$locality

echo "Please input State or Province"
read state
subjects[ST]=$state

echo "Please input Country ISO-code (two capital letters)"
read country
while [[ !( $country =~ ^[A-Z]{2}$ ) ]]; do
  echo "Please input Country ISO-code [FI] (hint: it's only two capital letters)"
  read country
done
subjects[C]=$country

checked=0

while [ $checked -eq 0 ]; do

  printf "%b\n" "\n\e[1;31mPlease verify the following information\e[0m\n"
  printf "%b\n" " CN: $certname\n Organization: $organization\n Division: $division\n Locality: $locality\n State: $state\n Country: $country \n"

  printf "%b\n" "Are these correct? (yes/no)"

  read answer
  if [ $answer == 'yes' ]; then

    for field in "${!subjects[@]}"; do
      if [ -n "${subjects[$field]}" ]; then
        subject+="/$field=${subjects[$field]}"
      fi
    done

    echo $subject

    openssl genrsa -aes256 -out $certname.key 2048
    openssl req -new -key $certname.key -out $certname.csr \
    -subj $subject
    less $certname.csr
    checked=1

  elif [ $answer == 'no' ]; then
    printf "%b\n" "\n\e[1;31mIf you want to correct something the corresponding number\nIf you want to discard input anything else\e[0m\n"
    printf "%b\n" " 1. Certificate Name\n 2. Organization\n 3. Division\n 4. Locality\n 5. State\n 6. Country"
    read fix
    case $fix in
      1)
        echo "Please input Certificate Name"
        read certname
        while [[ -z $certname ]]; do
          echo Certificate name is oblicatory!
          read certname
        done
        subjects[CN]=$certname
      ;;

      2)
        echo "Please input Organization Name"
        read organization
        subjects[O]=$organization
        ;;

      3)
        echo "Please input Division Name"
        read division
        subjects[OU]=$division
        ;;

      4)
        echo "Please input Locality"
        read locality
        subjects[L]=$locality
        ;;

      5)
        echo "Please input State or Province"
        read state
        subjects[ST]=$state
        ;;

      6)
        echo "Please input Country ISO-code (two capital letters)"
        read country
        while [[ !( $country =~ ^[A-Z]{2}$ ) ]]; do
          echo "Please input Country ISO-code [FI] (hint: it's only two capital letters)"
          read country
        done
        subjects[C]=$country
        ;;
      *)
        echo Discarding information
        checked=1
        ;;
    esac

  else
    echo Please input yes or no
  fi
done
